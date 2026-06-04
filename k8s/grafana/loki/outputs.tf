output "release_name" {
  description = "Helm release name for Loki"
  value       = helm_release.loki.name
}

output "release_namespace" {
  description = "Namespace where Loki is deployed"
  value       = helm_release.loki.namespace
}

output "cluster_url" {
  description = "Cluster-internal base URL for Loki (SingleBinary HTTP)."
  value       = "http://${helm_release.loki.name}.${var.namespace_name}.svc.cluster.local:3100"
}

output "cluster_push_url" {
  description = "Cluster-internal URL for the Loki log push API."
  value       = "http://${helm_release.loki.name}.${var.namespace_name}.svc.cluster.local:3100/loki/api/v1/push"
}
