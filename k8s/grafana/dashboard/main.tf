# Grafana Community Helm chart: https://github.com/grafana-community/helm-charts/tree/main/charts/grafana

resource "random_password" "admin_password" {
  count   = var.admin_existing_secret_name == null && var.admin_password == null ? 1 : 0
  length  = 24
  special = true
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana-community.github.io/helm-charts"
  chart      = "grafana"
  version    = var.chart_version
  namespace  = var.namespace_name

  create_namespace = false

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 300

  set = concat(
    [
      {
        name  = "adminUser"
        value = var.admin_user
      },
      {
        name  = "replicas"
        value = tostring(var.replicas)
      },
      {
        name  = "resources.requests.cpu"
        value = local.resources_values.requests.cpu
      },
      {
        name  = "resources.requests.memory"
        value = local.resources_values.requests.memory
      },
      {
        name  = "resources.limits.cpu"
        value = local.resources_values.limits.cpu
      },
      {
        name  = "resources.limits.memory"
        value = local.resources_values.limits.memory
      },
    ],
    var.admin_existing_secret_name != null ? [{
      name  = "admin.existingSecret"
      value = var.admin_existing_secret_name
    }] : []
  )

  set_sensitive = var.admin_existing_secret_name == null ? [
    {
      name  = "adminPassword"
      value = local.admin_password
      type  = "string"
    }
  ] : []

  values = concat(
    length(var.env) > 0 ? [yamlencode({ env = var.env })] : [],
    length(local.datasources_values) > 0 ? [
      yamlencode({
        datasources = local.datasources_values
      })
    ] : []
  )
}
