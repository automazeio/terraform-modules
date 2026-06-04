output "namespace" {
  description = "Namespace where Harbor is deployed"
  value       = var.namespace_name
}

output "registry_url" {
  description = "External URL of the Harbor registry"
  value       = var.external_url
}

output "admin_password" {
  description = "Harbor admin password (from variable or generated). Use only when needed; prefer changing password in Harbor UI."
  value       = var.harbor_admin_password != null ? var.harbor_admin_password : random_password.harbor_admin[0].result
  sensitive   = true
}

output "release_name" {
  description = "Helm release name for Harbor"
  value       = helm_release.harbor.name
}

output "service_account_name" {
  description = "ServiceAccount name used by Harbor components (created in-module or passed via service_account_name)."
  value       = var.service_account_name != null ? var.service_account_name : kubernetes_service_account_v1.registry[0].metadata[0].name
}

# Harbor Helm chart names the registry service as (fullname)-registry. Chart fullname is Release.Name when it contains "harbor", else Release.Name + "-harbor".
output "internal_registry_url" {
  description = "In-cluster URL (host:port) for pulling images from Harbor registry. Use as base for container_image, e.g. <internal_registry_url>/project/repo:tag"
  value       = "${local.registry_service_name}.${var.namespace_name}.svc.cluster.local:5000"
}
