# DNS API token secret for cert-manager DNS-01 challenges

resource "kubernetes_secret_v1" "dns_api_token" {
  metadata {
    name      = "dns-api-token-${var.dns01_provider.name}-${var.environment}"
    namespace = "cert-manager"
  }

  data = {
    api-token = var.dns01_provider != null ? var.dns01_provider.api_token : ""
  }

  type = "Opaque"
}
