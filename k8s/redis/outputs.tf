output "connection_string" {
  description = "Connection string for Redis (with password)"
  value       = "redis://default:${random_password.redis_password.result}@${local.connection_host}:6379"
}

output "release_name" {
  description = "Helm release name (also the prefix of the chart's Services and Secret)"
  value       = helm_release.redis.name
}

output "master_pod_selector" {
  description = "Pod labels that select the current Redis master, for building a Service in front of it"
  value       = local.master_pod_selector
}
