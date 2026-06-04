variable "namespace_name" {
  description = "Kubernetes namespace name where API resources will be created"
  type        = string
}

variable "watch_namespaces" {
  description = "Namespaces to watch for pods"
  type        = list(string)
}

variable "location_label" {
  description = "Location label (e.g., 'eu', 'us', 'au'). Omit to skip the external label."
  type        = string
  default     = null
}

variable "loki_remote_write_url" {
  description = "Loki push endpoint URL (e.g. https://loki.example.com/loki/api/v1/push)."
  type        = string
}

variable "loki_remote_write_username" {
  description = "Basic auth username for Loki push. Leave null to disable basic auth (e.g. when targeting an in-cluster service)."
  type        = string
  default     = null
}

variable "loki_remote_write_password" {
  description = "Basic auth password for Loki push. Leave null to disable basic auth."
  type        = string
  sensitive   = true
  default     = null
}

variable "metrics_remote_write_url" {
  description = "Prometheus remote-write endpoint URL (e.g., https://prometheus.example.com/api/v1/write)"
  type        = string
}

variable "metrics_remote_write_username" {
  description = "Basic auth username for Prometheus remote-write. Leave null to disable basic auth (e.g. when targeting an in-cluster service)."
  type        = string
  default     = "alloy"
}

variable "metrics_remote_write_password" {
  description = "Basic auth password for Prometheus remote-write. Leave null to disable basic auth."
  type        = string
  sensitive   = true
  default     = null
}

variable "resources" {
  description = "Resource requests and limits for the Alloy container."
  type = object({
    requests = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }), {})
    limits = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }), {})
  })
  default = {
    requests = {
      cpu    = "50m"
      memory = "512Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "1Gi"
    }
  }
}
