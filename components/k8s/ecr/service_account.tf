# Note: ECR registry secret is managed by the Jobs below using kubectl
# This allows the jobs to update the secret without Terraform conflicts

# ServiceAccount for ECR token management
# Note: image_pull_secret will be added manually after the secret is created by the job
resource "kubernetes_service_account_v1" "ecr_service_account" {
  metadata {
    name      = "ecr-service-account"
    namespace = var.namespace_name
  }

  # image_pull_secret will be patched by the job after secret creation

  lifecycle {
    ignore_changes = [image_pull_secret]
  }
}
