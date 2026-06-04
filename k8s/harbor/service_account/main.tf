# Image pull secret for Harbor (external URL); auth so node can pull when request reaches Harbor.
resource "kubernetes_secret_v1" "harbor_pull" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace_name
  }
  type = "kubernetes.io/dockerconfigjson"
  binary_data = {
    ".dockerconfigjson" = base64encode(jsonencode({
      auths = {
        (var.harbor_host) = {
          auth = base64encode("admin:${var.harbor_admin_password}")
        }
      }
    }))
  }
}

# ServiceAccount that carries Harbor image-pull credentials; any pod using this SA can pull from Harbor.
resource "kubernetes_service_account_v1" "harbor_pull" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace_name
  }
  image_pull_secret {
    name = kubernetes_secret_v1.harbor_pull.metadata[0].name
  }
}
