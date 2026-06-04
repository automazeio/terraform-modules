# Optional ingress: /loki/api/v1/push and /ready, with optional Basic auth
module "ingress" {
  count  = length(var.ingress_hosts) > 0 && var.letsencrypt_name != null ? 1 : 0
  source = "../../single_deployment/ingress"

  name             = "loki"
  namespace        = var.namespace_name
  hosts            = var.ingress_hosts
  path_prefixes    = ["/loki/api/v1/push", "/ready"]
  letsencrypt_name = var.letsencrypt_name
  service_name     = "loki"
  service_port     = 3100
  username         = var.ingress_username
  password         = var.ingress_password
  labels = {
    app        = "loki"
    managed-by = "Opentofu"
  }

  providers = {
    kubernetes = kubernetes
  }

  depends_on = [helm_release.loki]
}
