output "connection_string" {
  description = "Connection string for Redis (with password)"
  value       = "redis://default:${random_password.redis_password.result}@${helm_release.redis.name}-master.${var.namespace_name}.svc.cluster.local:6379"
}
