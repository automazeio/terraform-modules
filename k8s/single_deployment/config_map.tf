resource "kubernetes_config_map_v1" "config_map" {
  metadata {
    name      = "${var.name}-config"
    namespace = var.namespace
    labels    = local.labels
  }

  data = local.config_map_data

  lifecycle {
    precondition {
      condition     = !var.node_auto_config || length(regexall("max[-_]old[-_]space[-_]size", local.caller_node_options)) == 0
      error_message = "node_auto_config manages --max-old-space-size; remove it from this deployment's config_map_data NODE_OPTIONS to avoid a duplicate flag (Node would silently use the last one)."
    }
  }
}
