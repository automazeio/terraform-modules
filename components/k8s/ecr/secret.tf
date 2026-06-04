resource "kubernetes_secret_v1" "ecr_credentials" {
  metadata {
    name      = "ecr-credentials"
    namespace = var.namespace_name
  }

  data = {
    AWS_ACCESS_KEY_ID     = var.ecr_access_key_id
    AWS_SECRET_ACCESS_KEY = var.ecr_secret_access_key
    AWS_DEFAULT_REGION    = var.aws_region
  }

  type = "Opaque"
}
