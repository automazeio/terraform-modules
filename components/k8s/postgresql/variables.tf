# Variables for PostgreSQL Helm deployment (Bitnami)

variable "namespace_name" {
  description = "Kubernetes namespace where PostgreSQL will be deployed"
  type        = string
}

variable "database" {
  description = "Name of the default database to create"
  type        = string
  default     = "postgres"
}

variable "username" {
  description = "PostgreSQL username (non-superuser for app connections)"
  type        = string
  default     = "postgres"
}

variable "persistence_enabled" {
  description = "Enable persistent storage for PostgreSQL data"
  type        = bool
  default     = false
}

variable "persistence_size" {
  description = "Size of the persistent volume (e.g. 8Gi). Used when persistence_enabled is true."
  type        = string
  default     = "8Gi"
}

variable "persistence_storage_class" {
  description = "Storage class for the persistent volume (e.g. longhorn). Omit to use cluster default."
  type        = string
  default     = null
}
