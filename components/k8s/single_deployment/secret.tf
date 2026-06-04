resource "kubernetes_secret_v1" "secret" {
  metadata {
    name      = "${var.name}-secret"
    namespace = var.namespace
    labels    = local.labels
  }

  data = var.secret_data

  type = "Opaque"
}
