output "workflow_content" {
  description = "Generated GitHub Actions workflow YAML content"
  value       = local.workflow_content
}

output "workflow_file_path" {
  description = "Path of the workflow file in the repository"
  value       = github_repository_file.workflow.file
}

output "workflow_sha" {
  description = "SHA of the committed workflow file blob"
  value       = github_repository_file.workflow.sha
}

output "image" {
  description = "Full container image reference (without tag) used in the workflow"
  value       = local.image
}

output "required_secret_names" {
  description = "GitHub Actions secret names required by the workflow (create these in the repo or pass values to the module)"
  value = {
    registry_username = var.registry_username_secret_name
    registry_password = var.registry_password_secret_name
    kubeconfig        = var.kubeconfig_secret_name
  }
}

output "deploy_env_var_names" {
  description = "Env var names used in the deploy job (for reference)"
  value = {
    kubeconfig      = var.kubeconfig_env_var_name
    kubeconfig_file = var.kubeconfig_file_path
  }
}
