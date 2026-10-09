
resource "random_password" "redis_password" {
  length  = 48
  special = false
}

resource "helm_release" "redis" {
  name       = var.release_name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "25.4.1"
  namespace  = var.namespace_name

  create_namespace = false

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = var.sentinel_enabled ? 600 : 120

  set = concat([
    {
      name  = "architecture"
      value = var.sentinel_enabled ? "replication" : "standalone"
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
        value = local.storage_size
      },
      ], var.storage_class_name == null ? [] : [
      {
        name  = "master.persistence.storageClass"
        value = var.storage_class_name
      },
  ]))

  values = concat([
    yamlencode({
      master = {
        resources  = local.redis_resources
        extraFlags = local.redis_extra_flags
      }
    })
    ], !var.sentinel_enabled ? [] : [
    # In replication + Sentinel mode the chart runs a single `<release>-node` StatefulSet
    # configured from `replica.*`; `master.*` is ignored.
    yamlencode({
      replica = {
        replicaCount                 = var.replica_count
        podAntiAffinityPreset        = var.pod_anti_affinity_preset
        automountServiceAccountToken = true
        resources                    = local.redis_resources
        extraFlags                   = local.redis_extra_flags
        persistence = merge(
          {
            enabled = var.persistence_enabled
            size    = local.storage_size
          },
          var.storage_class_name == null ? {} : { storageClass = var.storage_class_name },
        )
      }

      sentinel = {
        enabled = true
        image = {
          repository = "bitnamilegacy/redis-sentinel"
          tag        = "8.2.1"
        }
        downAfterMilliseconds = var.sentinel_down_after_milliseconds

        masterService = {
          enabled = true
        }
        resources = {
          requests = {
            cpu    = "25m"
            memory = "64Mi"
          }
          limits = {
            memory = "128Mi"
          }
        }
      }

      kubectl = {
        image = {
          repository = "bitnamilegacy/kubectl"
          tag        = "1.33.4"
        }
        resources = {
          requests = {
            cpu    = "10m"
            memory = "32Mi"
          }
          limits = {
            memory = "96Mi"
          }
        }
      }

      rbac = {
        create = true
      }
      serviceAccount = {
        create = true
      }
    })
  ])
}
