# ECR Module Outputs

output "service_account_name" {
  description = "Name of the service account configured with ECR access"
  value       = kubernetes_service_account_v1.ecr_service_account.metadata[0].name
}

output "repository_url" {
  description = "ECR repository URL"
  value       = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}
