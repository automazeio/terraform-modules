# Variables for Redis Helm deployment

variable "namespace_name" {
  description = "Kubernetes namespace where Redis will be deployed"
  type        = string
}

variable "storage_class_name" {
  description = "StorageClass for the Redis PVC. Leave null to use the cluster default."
  type        = string
  default     = null
}

variable "persistence_enabled" {
  description = "Whether to enable persistence for Redis."
  type        = bool
  default     = true
}

variable "max_memory" {
  description = "Maximum memory (in Mi) for the Redis master."
  type        = number
  default     = 800
}
