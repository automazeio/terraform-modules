output "local_url" {
  description = "Local URL for accessing the API within the cluster"
  value       = "http://${kubernetes_service_v1.service.metadata[0].name}.${var.namespace}.svc.cluster.local"
}

output "public_urls" {
  description = "Public URLs for accessing the API"
  value       = [for host in var.hosts : "https://${host}"]
}
