locals {
  max_cpu    = 100
  max_memory = 128
}

locals {
  ecr_secret_name = "ecr-registry-secret"
  ecr_server      = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"

  # Common ECR token refresh script
  ecr_token_script = <<-EOT
    echo "Installing AWS CLI..."
    apk add --no-cache aws-cli
    echo "Getting ECR token..."
    TOKEN=$(aws ecr get-login-password --region ${var.aws_region})
    
    # Create or update the ECR registry secret
    echo "Creating/updating ECR registry secret..."
    kubectl create secret docker-registry ${local.ecr_secret_name} \
      --docker-server=${local.ecr_server} \
      --docker-username=AWS \
      --docker-password=$TOKEN \
      --docker-email=dummy@example.com \
      --namespace=${var.namespace_name} \
      --save-config \
      --dry-run=client -o yaml | kubectl apply -f -
    
    # Patch the service account to include the image pull secret
    echo "Updating service account with image pull secret..."
    kubectl patch serviceaccount ${kubernetes_service_account_v1.ecr_service_account.metadata[0].name} \
      -p '{"imagePullSecrets":[{"name":"${local.ecr_secret_name}"}]}' \
      --namespace=${var.namespace_name}
    
    echo "ECR token and service account updated successfully"
  EOT

  # Common container configuration for ECR token jobs
  ecr_container_config = {
    name    = "ecr-token-updater"
    image   = "alpine/k8s:1.34.0"
    command = ["/bin/sh", "-c", local.ecr_token_script]
    env_from = [{
      secret_ref = {
        name = kubernetes_secret_v1.ecr_credentials.metadata[0].name
      }
    }]
    resources = {
      limits = {
        cpu    = "${local.max_cpu}m"
        memory = "${local.max_memory}Mi"
      }
      requests = {
        cpu    = "${floor(local.max_cpu * 0.5)}m"
        memory = "${floor(local.max_memory * 0.5)}Mi"
      }
    }
  }
}
