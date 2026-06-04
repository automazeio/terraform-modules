# TLS certificate via cert-manager (ClusterIssuer)
resource "kubernetes_manifest" "certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "${var.name}-certificate"
      namespace = var.namespace
      labels    = var.labels
    }
    spec = {
      secretName = "${var.name}-certificate-tls"
      issuerRef = {
        name = var.letsencrypt_name
        kind = "ClusterIssuer"
      }
      dnsNames = var.hosts
    }
  }
}

# Secret for Traefik BasicAuth middleware (kubernetes.io/basic-auth: username + password keys)
resource "kubernetes_secret_v1" "basic_auth" {
  count = var.username != null && var.password != null ? 1 : 0

  metadata {
    name      = "${var.name}-basic-auth"
    namespace = var.namespace
    labels    = var.labels
  }

  data = {
    username = var.username
    password = var.password
  }

  type = "kubernetes.io/basic-auth"
}

# Traefik Middleware: BasicAuth using the secret
resource "kubernetes_manifest" "middleware_basic_auth" {
  count = var.username != null && var.password != null ? 1 : 0

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "${var.name}-basic-auth"
      namespace = var.namespace
      labels    = var.labels
    }
    spec = {
      basicAuth = {
        secret = kubernetes_secret_v1.basic_auth[0].metadata[0].name
      }
    }
  }

  depends_on = [kubernetes_secret_v1.basic_auth]
}

# Traefik Ingress with HTTPS redirect; optional Basic auth via middleware
resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "${var.name}-ingress"
    namespace = var.namespace
    labels    = var.labels
    annotations = merge(
      {
        "traefik.ingress.kubernetes.io/router.entrypoints" = "web,websecure"
        "traefik.ingress.kubernetes.io/redirect-to-https"  = "true"
      },
      var.username != null && var.password != null ? {
        "traefik.ingress.kubernetes.io/router.middlewares" = "${var.namespace}-${var.name}-basic-auth@kubernetescrd"
      } : {}
    )
  }

  spec {
    ingress_class_name = "traefik"

    tls {
      hosts       = var.hosts
      secret_name = "${var.name}-certificate-tls"
    }

    dynamic "rule" {
      for_each = var.hosts
      content {
        host = rule.value
        http {
          dynamic "path" {
            for_each = var.path_prefixes
            content {
              path      = path.value
              path_type = "Prefix"
              backend {
                service {
                  name = var.service_name
                  port {
                    number = var.service_port
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.certificate]
}
