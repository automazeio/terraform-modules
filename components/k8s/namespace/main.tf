resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    name = var.name
    labels = {
      managed-by = "terraform"
    }
  }
}
