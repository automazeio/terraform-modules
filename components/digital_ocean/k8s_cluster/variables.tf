variable "region_config" {
  description = "Configuration for the region where the cluster will be deployed"
  type = object({
    name     = string
    location = string
  })
}

variable "node_count" {
  description = "Number of worker nodes in the node pool"
  type        = number
  default     = 1
}

variable "high_availability" {
  description = "Whether to deploy a high availability control plane"
  type        = bool
  default     = false
}

variable "node_size" {
  description = "Size of the worker nodes"
  type        = string
}

variable "maintenance_policy" {
  description = "Maintenance policy for the cluster"
  type = object({
    day        = string
    start_time = string
  })
  default = {
    day        = "saturday"
    start_time = "00:00"
  }
}