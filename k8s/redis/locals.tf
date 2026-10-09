locals {
  max_cpu    = 500
  max_memory = var.max_memory

  storage_size = var.storage_size != null ? var.storage_size : "${ceil(local.max_memory * 1.5)}Mi"

  redis_resources = {
    limits = {
      cpu    = "${local.max_cpu}m"
      memory = "${local.max_memory}Mi"
    }
    requests = {
      cpu    = "${floor(local.max_cpu * 0.5)}m"
      memory = "${local.max_memory}Mi"
    }
  }

  redis_extra_flags = [
    "--maxmemory", "${floor(local.max_memory * 0.9)}mb",
    "--maxmemory-policy", var.maxmemory_policy,
  ]

  master_pod_selector = merge(
    {
      "app.kubernetes.io/instance" = helm_release.redis.name
      "app.kubernetes.io/name"     = "redis"
    },
    var.sentinel_enabled ? { "isMaster" = "true" } : { "app.kubernetes.io/component" = "master" },
  )

  connection_host = coalesce(var.connection_host, "${helm_release.redis.name}-master.${var.namespace_name}.svc.cluster.local")
}
