output "release_name" {
  description = "Helm release name for Grafana"
  value       = helm_release.grafana.name
}

output "release_namespace" {
  description = "Namespace where Grafana is deployed"
  value       = helm_release.grafana.namespace
}

output "service_name" {
  description = "Kubernetes service name for Grafana (for ingress or port-forward)"
  value       = "${helm_release.grafana.name}.${var.namespace_name}.svc.cluster.local"
}

output "admin_password" {
  description = "Grafana admin password (when not using existing secret)"
  value       = var.admin_existing_secret_name == null ? local.admin_password : null
  sensitive   = true
}
