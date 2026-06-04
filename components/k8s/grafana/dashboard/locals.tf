locals {
  # When using existing secret, password is null. Otherwise use var or generated (only reference random_password when it exists).
  admin_password = var.admin_existing_secret_name != null ? null : (var.admin_password != null ? var.admin_password : random_password.admin_password[0].result)

  # Build datasources map for chart: key = filename (e.g. datasources.yaml), value = content
  datasources_values = length(var.datasources) > 0 ? {
    for name, content in var.datasources : name => content
  } : {}

  max_cpu    = 400
  max_memory = 750

  resources_values = {
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
