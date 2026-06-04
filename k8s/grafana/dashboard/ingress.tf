# Optional TLS + Ingress (reuses single_deployment/ingress module)
module "ingress" {
  count  = length(var.ingress_hosts) > 0 && var.letsencrypt_name != null ? 1 : 0
  source = "../../single_deployment/ingress"

  name             = "grafana"
  namespace        = var.namespace_name
  hosts            = var.ingress_hosts
  path_prefixes    = ["/"]
  letsencrypt_name = var.letsencrypt_name
  service_name     = "grafana"
  service_port     = 80
  labels = {
    app        = "grafana"
    managed-by = "Opentofu"
  }

  providers = {
    kubernetes = kubernetes
  }

  depends_on = [helm_release.grafana]
}
