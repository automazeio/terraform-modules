output "release_name" {
  description = "Helm release name for Databasus"
  value       = helm_release.databasus.name
}

output "release_namespace" {
  description = "Namespace where Databasus is deployed"
  value       = helm_release.databasus.namespace
}

output "service_name" {
  description = "Kubernetes service name for Databasus (for port-forward or internal access)"
  value       = "databasus-service"
}

output "service_port" {
  description = "Port the Databasus UI listens on"
  value       = 4005
}
