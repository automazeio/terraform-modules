output "repository_names" {
  description = "The GitHub repository names"
  value       = var.repository_names
}

output "secrets_created" {
  description = "Map of secrets created per repository"
  value = {
    for repo in var.repository_names : repo => "tf_KUBECONFIG_${var.region_config.name}"
  }
}

output "secret_name" {
  description = "The name of the secret created"
  value       = "tf_KUBECONFIG_${var.region_config.name}"
}
