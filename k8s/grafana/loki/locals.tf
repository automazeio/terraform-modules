locals {
  resources_values = {
    requests = merge(
      # memory request grounded in live usage (~376Mi); 256Mi under-reserved at schedule time
      { cpu = "100m", memory = "384Mi" },
      try(var.resources.requests, {})
    )
    limits = merge(
      { cpu = "1000m", memory = "1Gi" },
      try(var.resources.limits, {})
    )
  }
}
