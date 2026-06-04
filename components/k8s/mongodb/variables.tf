variable "namespace_name" {
  description = "Kubernetes namespace where MongoDB will be deployed"
  type        = string
}

variable "persistence_size" {
  description = "PVC storage size for MongoDB data"
  type        = string
  default     = "10Gi"
}

variable "persistence_storage_class" {
  description = "Storage class for MongoDB persistence"
  type        = string
  default     = "longhorn"
}

variable "root_user" {
  description = "Root username for MongoDB."
  type        = string
  default     = "root"
}

variable "root_password" {
  description = "Custom root password. If not set, a random 48-character password is generated."
  type        = string
  default     = null
  sensitive   = true
}

variable "ingress_host" {
  description = "Hostname for external TCP access. Empty string disables ingress."
  type        = string
  default     = ""
}

variable "letsencrypt_name" {
  description = "Name of the cert-manager ClusterIssuer for TLS"
  type        = string
  default     = null
}

variable "resources_preset" {
  description = "Preset for resource limits and requests"
  type        = string
  default     = "nano"
}