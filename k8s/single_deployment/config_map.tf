resource "kubernetes_config_map_v1" "config_map" {
  metadata {
    name      = "${var.name}-config"
    namespace = var.namespace
    labels    = local.labels
  }

  data = var.config_map_data
}
