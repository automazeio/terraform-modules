# Databasus — database backup tool (PostgreSQL, MySQL, MongoDB)
# https://github.com/databasus/databasus

resource "helm_release" "databasus" {
  name      = "databasus"
  chart     = "oci://ghcr.io/databasus/charts/databasus"
  version   = var.chart_version
  namespace = var.namespace_name

  create_namespace = var.create_namespace

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 300

  values = [
    yamlencode({
      persistence = {
        enabled          = true
        storageClassName = var.persistence_storage_class
        size             = var.persistence_size
      }
    })
  ]
}

# Optional ingress when ingress_hosts and letsencrypt_name are set (Traefik + cert-manager)
module "ingress" {
  count  = length(var.ingress_hosts) > 0 && var.letsencrypt_name != null ? 1 : 0
  source = "../single_deployment/ingress"

  name             = "databasus"
  namespace        = var.namespace_name
  hosts            = var.ingress_hosts
  path_prefixes    = ["/"]
  letsencrypt_name = var.letsencrypt_name
  service_name     = "databasus-service"
  service_port     = 4005
  labels = {
    app        = "databasus"
    managed-by = "terraform"
  }

  providers = {
    kubernetes = kubernetes
  }

  depends_on = [helm_release.databasus]
}
