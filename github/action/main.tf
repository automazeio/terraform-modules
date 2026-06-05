# GitHub Actions workflow: Build & Push to container registry, Deploy to cluster (single region)

locals {
  image = "${var.registry_host}/${var.image_repository}"
}

locals {
  workflow_content = templatefile("${path.module}/workflow.yaml.tftpl", {
    branch                        = var.branch
    registry_host                 = var.registry_host
    image                         = local.image
    registry_username_secret_name = var.registry_username_secret_name
    registry_password_secret_name = var.registry_password_secret_name
    dockerfile_path               = var.dockerfile_path
    context                       = var.context
    deployment_names              = var.deployment_names
    namespace                     = var.namespace
    kubeconfig_secret_name        = var.kubeconfig_secret_name
    kubeconfig_env_var_name       = var.kubeconfig_env_var_name
    kubeconfig_file_path          = var.kubeconfig_file_path
    build_args                    = var.build_args
    build_args_literals           = var.build_args_literals
  })
}

resource "github_repository_file" "workflow" {
  repository          = var.repository
  branch              = var.branch
  file                = ".github/workflows/${var.workflow_filename}"
  content             = local.workflow_content
  commit_message      = var.commit_message
  commit_author       = var.commit_author
  commit_email        = var.commit_email
  overwrite_on_create = true
}
