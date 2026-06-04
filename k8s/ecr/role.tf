# RBAC for ECR token management (shared by both CronJob and initial Job)
resource "kubernetes_role_v1" "ecr_token_manager" {
  metadata {
    name      = "ecr-token-manager-role"
    namespace = var.namespace_name
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "create", "update", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts"]
    verbs      = ["get", "patch"]
  }
}

resource "kubernetes_role_binding_v1" "ecr_token_manager" {
  metadata {
    name      = "ecr-token-manager-role-binding"
    namespace = var.namespace_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.ecr_token_manager.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.ecr_service_account.metadata[0].name
    namespace = var.namespace_name
  }
}
