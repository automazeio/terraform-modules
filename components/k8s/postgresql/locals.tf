locals {
  max_cpu    = 500
  max_memory = 512

  persistence_set = concat(
    [],
    var.persistence_storage_class != null && var.persistence_storage_class != "" ? [{
      name  = "primary.persistence.storageClass"
      value = var.persistence_storage_class
    }] : []
  )
}
