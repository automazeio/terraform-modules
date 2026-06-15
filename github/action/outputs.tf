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
  description = "GitHub Actions secret names referenced by the generated workflow (create these in the repo or pass values to the module)."
  value = merge(
    { for c in local.clusters : "kubeconfig_${c.name}" => c.kubeconfig_secret_name },
    var.registry_type == "ecr" ? {
      aws_access_key_id     = var.aws_access_key_id_secret_name
      aws_secret_access_key = var.aws_secret_access_key_secret_name
      } : {
      registry_username = var.registry_username_secret_name
      registry_password = var.registry_password_secret_name
    }
  )
}

output "deploy_env_var_names" {
  description = "Env var names used in the deploy job (for reference)"
  value = {
    kubeconfig      = var.kubeconfig_env_var_name
    kubeconfig_file = var.kubeconfig_file_path
  }
}
