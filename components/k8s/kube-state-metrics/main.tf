resource "helm_release" "kube_state_metrics" {
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version    = var.chart_version
  namespace  = var.namespace_name

  create_namespace = var.create_namespace

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 120
}
