# TLS Certificate (optional): when certificate_issuer_name is set, create a cert-manager Certificate
resource "kubernetes_manifest" "harbor_certificate" {
  count = var.certificate_issuer_name != null && var.ingress_host != null ? 1 : 0

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "harbor-tls"
      namespace = var.namespace_name
    }
    spec = {
      secretName = var.ingress_tls_secret
      issuerRef = {
        name = var.certificate_issuer_name
        kind = var.certificate_issuer_kind
      }
      dnsNames = [var.ingress_host]
    }
  }
}

# Admin password: use provided value or generate random and store in secret

resource "random_password" "harbor_admin" {
  count = var.harbor_admin_password == null ? 1 : 0

  length  = 24
  special = true
}

resource "kubernetes_secret_v1" "harbor_admin_password" {
  metadata {
    name      = "harbor-admin-password"
    namespace = var.namespace_name
  }
  data = {
    HARBOR_ADMIN_PASSWORD = var.harbor_admin_password != null ? var.harbor_admin_password : random_password.harbor_admin[0].result
  }
}

# ServiceAccount for Harbor components (image pull / registry identity). Created when service_account_name is not provided.
resource "kubernetes_service_account_v1" "registry" {
  count = var.service_account_name == null ? 1 : 0

  metadata {
    name      = var.service_account_name_created
    namespace = var.namespace_name
  }
}

locals {
  effective_sa_name = var.service_account_name != null ? var.service_account_name : kubernetes_service_account_v1.registry[0].metadata[0].name
  # Harbor Helm chart: registry service = (fullname)-registry; fullname = Release.Name if it contains "harbor", else Release.Name + "-harbor"
  registry_fullname     = strcontains(helm_release.harbor.name, "harbor") ? helm_release.harbor.name : "${helm_release.harbor.name}-harbor"
  registry_service_name = "${local.registry_fullname}-registry"
}

# Harbor Helm release

locals {
  expose_ingress_host = var.expose_type == "ingress" ? coalesce(var.ingress_host, replace(replace(var.external_url, "https://", ""), "http://", "")) : null
  persistence_values = {
    enabled = var.persistence_enabled
    persistentVolumeClaim = var.persistence_enabled ? {
      registry = {
        size = var.registry_storage_size
      }
      database = {
        size = var.database_storage_size
      }
    } : {}
  }
  # Single merge so we never pass tls with empty secretName (chart would mount invalid secret).
  expose_values = merge(
    {
      type = var.expose_type == "ingress" && local.expose_ingress_host != null ? "ingress" : var.expose_type
    },
    var.expose_type == "ingress" && local.expose_ingress_host != null ? {
      ingress = {
        hosts     = { core = local.expose_ingress_host }
        className = var.ingress_class_name
        annotations = merge(
          {
            "ingress.kubernetes.io/ssl-redirect"    = "true"
            "ingress.kubernetes.io/proxy-body-size" = "0"
          },
          var.ingress_annotations
        )
      }
    } : {},
    # When ingress: pass certSource "secret" or "none". Chart nginx/secret.yaml has required "expose.tls.auto.commonName" that can still run due to merge order; always set auto.commonName so it never fails.
    var.expose_type == "ingress" && local.expose_ingress_host != null ? (
      var.ingress_tls_secret != null
      ? { tls = { certSource = "secret", enabled = true, secret = { secretName = var.ingress_tls_secret }, auto = { commonName = local.expose_ingress_host } } }
      : { tls = { certSource = "none", enabled = false, secret = { secretName = "" }, auto = { commonName = local.expose_ingress_host } } }
    ) : {}
  )
}

# Resource requests/limits per Harbor component. Sized from live usage
# (kubectl top -n harbor) + headroom; memory-limited only, no CPU limit (avoids
# throttling). trivy is omitted — the chart already sets its resources.
# NOTE: registry idles around ~1.3Gi (Go heap not returned to the OS), so it gets a
# deliberately generous 2Gi cap to avoid OOM during GC / large layer pushes.
locals {
  harbor_resources = {
    # core hosts the /v2/ token service; a push + Trivy scan burst spiked it past
    # 256Mi and OOMKilled it (exit 137), 503-ing docker logins. 512Mi gives headroom.
    core        = { requests = { cpu = "50m", memory = "128Mi" }, limits = { memory = "512Mi" } }
    jobservice  = { requests = { cpu = "50m", memory = "128Mi" }, limits = { memory = "256Mi" } }
    portal      = { requests = { cpu = "10m", memory = "32Mi" }, limits = { memory = "64Mi" } }
    registry    = { requests = { cpu = "100m", memory = "512Mi" }, limits = { memory = "2Gi" } }
    registryctl = { requests = { cpu = "50m", memory = "64Mi" }, limits = { memory = "128Mi" } }
    database    = { requests = { cpu = "100m", memory = "256Mi" }, limits = { memory = "512Mi" } }
    redis       = { requests = { cpu = "50m", memory = "64Mi" }, limits = { memory = "128Mi" } }
  }
}

# Per-component values: serviceAccountName (created in-module or passed in) + resources.
locals {
  component_values = {
    nginx      = { serviceAccountName = local.effective_sa_name }
    portal     = { serviceAccountName = local.effective_sa_name, resources = local.harbor_resources.portal }
    core       = { serviceAccountName = local.effective_sa_name, resources = local.harbor_resources.core }
    jobservice = { serviceAccountName = local.effective_sa_name, resources = local.harbor_resources.jobservice }
    registry = {
      registry   = { resources = local.harbor_resources.registry }
      controller = { serviceAccountName = local.effective_sa_name, resources = local.harbor_resources.registryctl }
    }
    trivy    = { serviceAccountName = local.effective_sa_name }
    database = { internal = { resources = local.harbor_resources.database } }
    redis    = { internal = { resources = local.harbor_resources.redis } }
  }
}

# Full expose block for ingress: single source of truth so chart always sees type=ingress and tls.auto.commonName (goharbor/harbor-helm#860).
locals {
  expose_for_ingress = var.expose_type == "ingress" && local.expose_ingress_host != null ? {
    type = "ingress"
    tls = {
      auto       = { commonName = local.expose_ingress_host }
      certSource = var.ingress_tls_secret != null ? "secret" : "none"
      enabled    = var.ingress_tls_secret != null
      secret     = var.ingress_tls_secret != null ? { secretName = var.ingress_tls_secret } : {}
    }
    ingress = {
      hosts     = { core = local.expose_ingress_host }
      className = var.ingress_class_name
      annotations = merge(
        { "ingress.kubernetes.io/ssl-redirect" = "true", "ingress.kubernetes.io/proxy-body-size" = "0" },
        var.ingress_annotations
      )
    }
  } : null
}

resource "helm_release" "harbor" {
  name       = "harbor"
  repository = "https://helm.goharbor.io"
  chart      = "harbor"
  version    = var.chart_version
  namespace  = var.namespace_name

  create_namespace = false

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 300

  depends_on = [kubernetes_manifest.harbor_certificate]

  # One values file only; when ingress use expose_for_ingress so expose is defined once with type + tls.auto.commonName.
  values = [
    yamlencode(merge(
      {
        externalURL                 = var.external_url
        existingSecretAdminPassword = kubernetes_secret_v1.harbor_admin_password.metadata[0].name
        persistence                 = local.persistence_values
        # registry & jobservice are Deployments on RWO Longhorn PVCs. The chart's
        # default RollingUpdate surges a second pod that can't multi-attach the volume,
        # deadlocking the rollout ("Multi-Attach error"). Recreate terminates the old
        # pod (releasing the volume) before starting the new one.
        updateStrategy = { type = "Recreate" }
      },
      local.expose_for_ingress != null ? { expose = local.expose_for_ingress } : { expose = local.expose_values },
      local.component_values
    ))
  ]
}
