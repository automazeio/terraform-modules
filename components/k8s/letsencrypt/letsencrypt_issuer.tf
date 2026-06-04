resource "kubernetes_manifest" "letsencrypt_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = local.environments[var.environment].name
    }
    spec = {
      acme = {
        server = local.environments[var.environment].server

        email = var.letsencrypt_email
        privateKeySecretRef = {
          name = local.environments[var.environment].name
        }
        solvers = concat(
          [
            {
              # HTTP-01 challenge for regular certificates
              http01 = {
                ingress = {
                  class = "traefik"
                }
              }
            }
          ],
          var.dns01_provider != null ? [
            {
              # DNS-01 challenge for wildcard certificates and when HTTP-01 isn't available
              dns01 = {
                (var.dns01_provider.name) = {
                  apiTokenSecretRef = {
                    name = kubernetes_secret_v1.dns_api_token.metadata[0].name
                    key  = "api-token"
                  }
                }
              }
              selector = {
                dnsZones = var.dns01_provider.dns_zones
              }
            }
          ] : []
        )
      }
    }
  }
}
