resource "random_password" "mongodb_root_password" {
  length  = 48
  special = false
}

resource "helm_release" "mongodb" {
  name       = "mongodb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb"
  version    = "18.6.21"
  namespace  = var.namespace_name

  create_namespace = false

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 300

  set = [
    {
      name  = "architecture"
      value = "standalone"
    },
    {
      name  = "useStatefulSet"
      value = "true"
    },
    {
      name  = "auth.enabled"
      value = "true"
    },
    {
      name  = "auth.rootUser"
      value = local.root_user
    },
    {
      name  = "auth.rootPassword"
      value = local.root_password
    },
    {
      name  = "persistence.enabled"
      value = "true"
    },
    {
      name  = "persistence.storageClass"
      value = var.persistence_storage_class
    },
    {
      name  = "persistence.size"
      value = var.persistence_size
    },
    {
      name  = "resourcesPreset"
      value = var.resources_preset
    },
  ]
}

module "gateway" {
  count  = length(var.ingress_host) > 0 && var.letsencrypt_name != null ? 1 : 0
  source = "../gateway"

  name             = "mongodb"
  namespace        = var.namespace_name
  hosts            = [var.ingress_host]
  letsencrypt_name = var.letsencrypt_name
  service_name     = helm_release.mongodb.name
  service_port     = 27017
  entrypoint       = "mongodb"

  providers = {
    kubernetes = kubernetes
  }

  depends_on = [helm_release.mongodb]
}
