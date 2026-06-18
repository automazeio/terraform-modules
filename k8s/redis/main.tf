
resource "random_password" "redis_password" {
  length  = 48
  special = false
}

resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "25.4.1"
  namespace  = var.namespace_name

  create_namespace = false

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 120

  set = concat([
    {
      name  = "architecture"
      value = "standalone"
    },
    {
      name  = "image.repository"
      value = "bitnamilegacy/redis"
    },
    {
      name  = "image.tag"
      value = "8.2.1"
    },
    {
      name  = "global.security.allowInsecureImages"
      value = "true"
    },
    {
      name  = "auth.enabled"
      value = tostring(var.auth_enabled)
    },
    {
      name  = "auth.password"
      value = random_password.redis_password.result
    },
    {
      name  = "master.persistence.enabled"
      value = tostring(var.persistence_enabled)
    },
    ], !var.persistence_enabled ? [] : concat([
      {
        name  = "master.persistence.size"
        value = "${ceil(local.max_memory * 1.5)}Mi"
      },
      ], var.storage_class_name == null ? [] : [
      {
        name  = "master.persistence.storageClass"
        value = var.storage_class_name
      },
  ]))

  values = [
    yamlencode({
      master = {
        resources = {
          limits = {
            cpu    = "${local.max_cpu}m"
            memory = "${local.max_memory}Mi"
          }
          requests = {
            cpu    = "${floor(local.max_cpu * 0.5)}m"
            memory = "${local.max_memory}Mi"
          }
        }
        extraFlags = [
          "--maxmemory", "${floor(local.max_memory * 0.9)}mb",
          "--maxmemory-policy", var.maxmemory_policy,
        ]
      }
    })
  ]
}
