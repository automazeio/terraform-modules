output "host" {
  description = "PostgreSQL host (Kubernetes service DNS)"
  value       = "${helm_release.postgresql.name}.${var.namespace_name}.svc.cluster.local"
}

output "port" {
  description = "PostgreSQL port"
  value       = 5432
}

output "database" {
  description = "Default database name"
  value       = var.database
}

output "username" {
  description = "PostgreSQL username"
  value       = var.username
}

output "password" {
  description = "PostgreSQL password"
  value       = random_password.postgres_password.result
  sensitive   = true
}

output "connection_string" {
  description = "PostgreSQL connection URI (password in URL)"
  value       = "postgresql://${var.username}:${random_password.postgres_password.result}@${helm_release.postgresql.name}.${var.namespace_name}.svc.cluster.local:5432/${var.database}"
  sensitive   = true
}

output "connection_string_env" {
  description = "PostgreSQL connection string for DATABASE_URL / POSTGRES_URL (no password in URL; use PGPASSWORD)"
  value       = "postgresql://${var.username}@${helm_release.postgresql.name}.${var.namespace_name}.svc.cluster.local:5432/${var.database}"
}
