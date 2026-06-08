locals {
  labels = {
    app        = var.name
    managed-by = "Opentofu"
  }

  # V8 old-space ceiling derived from the memory limit when node_auto_config is on.
  # null = leave NODE_OPTIONS untouched (non-Node image, auto off, or no limit set).
  node_max_old_space_size_mb = var.node_auto_config && var.max_resources != null ? floor(var.max_resources.memory * var.node_max_old_space_size_ratio) : null

  caller_node_options = lookup(var.config_map_data, "NODE_OPTIONS", "")

  # Append --max-old-space-size to whatever NODE_OPTIONS the caller set, keeping
  # their other flags. The heap cap is a single source of truth that tracks the
  # container limit this module owns. The duplicate-flag guard lives on the
  # config map resource (Node silently uses the last of duplicate flags).
  config_map_data = local.node_max_old_space_size_mb == null ? var.config_map_data : merge(
    var.config_map_data,
    {
      NODE_OPTIONS = trimspace("${local.caller_node_options} --max-old-space-size=${local.node_max_old_space_size_mb}")
    }
  )
}
