locals {
  ingress_replica_count = var.agent_count > 2 ? 3 : var.agent_count >= 2 ? 2 : 1
}

resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  version          = "39.0.7"
  namespace        = "traefik"
  create_namespace = true

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 120

  set = [
    {
      name  = "autoscaling.enabled"
      value = "true"
    },
    {
      name  = "autoscaling.minReplicas"
      value = tostring(local.ingress_replica_count)
    },
    {
      name  = "autoscaling.maxReplicas"
      value = tostring(local.ingress_replica_count)
    },
    {
      name  = "podDisruptionBudget.enabled"
      value = "true"
    },
    {
      name  = "podDisruptionBudget.maxUnavailable"
      value = "33%"
    },
    {
      name  = "providers.kubernetesGateway.enabled"
      value = "true"
    },
    {
      name  = "ports.websecure.http3.enabled"
      value = "true"
    },
    { name  = "ports.web.http.redirections.entryPoint.permanent"
      value = "true"
    },
    {
      name  = "ports.web.http.redirections.entryPoint.scheme"
      value = "https"
    },
    {
      name  = "ports.web.http.redirections.entryPoint.to"
      value = "websecure"
    },
    {
      name  = "service.ipFamilyPolicy"
      value = "PreferDualStack"
    },
  ]

  values = [
    yamlencode({
      ports = {
        web = {
          proxyProtocol = {
            trustedIPs = ["127.0.0.1/32", "10.0.0.0/8"]
          }
        }
        websecure = {
          proxyProtocol = {
            trustedIPs = ["127.0.0.1/32", "10.0.0.0/8"]
          }
        }
      }
      resources = {
        requests = {
          memory = "50Mi"
          cpu    = "100m"
        }

        limits = {
          memory = "150Mi"
          cpu    = "300m"
        }
      }
      # Pin the system log to INFO to match the kube-hetzner Traefik (both
      # configs kept identical). Access log left OFF on purpose: Alloy doesn't
      # ship the `traefik` namespace to Loki, so access lines would only reach
      # pod stdout and never be queryable for 502 attribution.
      logs = {
        general = {
          level = "INFO"
        }
      }
    })
  ]
}

data "kubernetes_service_v1" "traefik" {
  metadata {
    name      = helm_release.traefik.name
    namespace = helm_release.traefik.namespace
  }
}
