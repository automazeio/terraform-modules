# GitHub Actions workflow: Build & Push to container registry, Deploy to cluster(s)

locals {
  image = var.image_uri != null ? var.image_uri : "${var.registry_host}/${var.image_repository}"

  # When no clusters are given, fall back to a single cluster built from
  # kubeconfig_secret_name so existing single-cluster callers keep working.
  clusters = length(var.clusters) > 0 ? var.clusters : [
    { name = "default", kubeconfig_secret_name = var.kubeconfig_secret_name }
  ]
}

locals {
  workflow_content = templatefile("${path.module}/workflow.yaml.tftpl", {
    branch                            = var.branch
    registry_type                     = var.registry_type
    registry_host                     = var.registry_host
    image                             = local.image
    registry_username_secret_name     = var.registry_username_secret_name
    registry_password_secret_name     = var.registry_password_secret_name
    aws_region                        = var.aws_region
    aws_access_key_id_secret_name     = var.aws_access_key_id_secret_name
    aws_secret_access_key_secret_name = var.aws_secret_access_key_secret_name
    dockerfile_path                   = var.dockerfile_path
    context                           = var.context
    deployment_names                  = var.deployment_names
    namespace                         = var.namespace
    clusters                          = local.clusters
    kubeconfig_env_var_name           = var.kubeconfig_env_var_name
    kubeconfig_file_path              = var.kubeconfig_file_path
    build_args                        = var.build_args
    build_args_literals               = var.build_args_literals
    image_tag_sha_prefix              = var.image_tag_sha_prefix
    latest_tag                        = var.latest_tag
    cancel_in_progress                = var.cancel_in_progress
    checkout_fetch_depth              = var.checkout_fetch_depth
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

  lifecycle {
    precondition {
      condition     = var.registry_type != "ecr" || var.aws_region != null
      error_message = "aws_region is required when registry_type = \"ecr\"."
    }
    precondition {
      condition     = var.image_uri != null || (var.registry_host != null && var.image_repository != null)
      error_message = "Set image_uri, or both registry_host and image_repository."
    }
  }
}
