module "ingress" {
  count  = length(var.hosts) > 0 ? 1 : 0
  source = "./ingress"

  name             = var.name
  namespace        = var.namespace
  hosts            = var.hosts
  path_prefixes    = [var.path_prefix]
  letsencrypt_name = var.letsencrypt_name
  service_name     = kubernetes_service_v1.service.metadata[0].name
  service_port     = 80
  labels           = local.labels

  providers = {
    kubernetes = kubernetes
  }
}
