# Bitnami PostgreSQL Helm chart: https://artifacthub.io/packages/helm/bitnami/postgresql

resource "random_password" "postgres_password" {
  length  = 32
  special = false
}

resource "helm_release" "postgresql" {
  name       = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "18.5.2"
  namespace  = var.namespace_name

  create_namespace = false

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 300

  set = concat(
    [
      {
        name  = "auth.username"
        value = var.username
      },
      {
        name  = "auth.password"
        value = random_password.postgres_password.result
      },
      {
        name  = "auth.database"
        value = var.database
      },
      {
        name  = "primary.persistence.enabled"
        value = tostring(var.persistence_enabled)
      },
      {
        name  = "primary.persistence.size"
        value = var.persistence_size
      },
    ],
    local.persistence_set
  )

  values = [
    yamlencode({
      primary = {
        resources = {
          limits = {
            cpu    = "${local.max_cpu}m"
            memory = "${local.max_memory}Mi"
          }
          requests = {
            cpu    = "${floor(local.max_cpu * 0.5)}m"
            memory = "${floor(local.max_memory * 0.5)}Mi"
          }
        }
      }
    })
  ]
}
