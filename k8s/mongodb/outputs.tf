output "connection_string" {
  description = "Connection string for MongoDB (with root credentials)"
  value       = "mongodb://${local.root_user}:${local.root_password}@${helm_release.mongodb.name}.${var.namespace_name}.svc.cluster.local:27017"
  sensitive   = true
}

output "connection_string_external" {
  description = "Connection string for MongoDB (with root credentials)"
  value       = "mongodb://${local.root_user}:${local.root_password}@${var.ingress_host}:27017"
  sensitive   = true
}


output "host" {
  description = "MongoDB host"
  value       = "${helm_release.mongodb.name}.${var.namespace_name}.svc.cluster.local"
}

output "port" {
  description = "MongoDB port"
  value       = 27017
}

output "root_user" {
  description = "MongoDB root username"
  value       = local.root_user
}

output "root_password" {
  description = "MongoDB root password"
  value       = local.root_password
  sensitive   = true
}
