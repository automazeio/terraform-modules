# Loki under grafana namespace (single binary, filesystem storage)

variable "namespace_name" {
  description = "Kubernetes namespace where Loki will be deployed (e.g. grafana)"
  type        = string
}

variable "chart_version" {
  description = "Loki Helm chart version"
  type        = string
  default     = "6.53.0"
}

variable "persistence_enabled" {
  description = "Enable persistent volume for Loki data (/loki, compactor working dir)"
  type        = bool
  default     = true
}

variable "persistence_size" {
  description = "Size of the persistent volume (e.g. 10Gi)"
  type        = string
  default     = "10Gi"
}

variable "persistence_storage_class" {
  description = "StorageClass for the Loki PVC (e.g. longhorn). Set to avoid unbound PVC when cluster has multiple or WaitForFirstConsumer default."
  type        = string
  default     = "longhorn"
}

variable "resources" {
  description = "Resource requests/limits for Loki (keys: requests, limits; each with cpu, memory)"
  type        = any
  default     = {}
}

# Optional ingress for push endpoint only (path /loki/api/v1/push), with Basic auth
variable "ingress_hosts" {
  description = "Host names for Loki push ingress (e.g. [\"loki.example.com\"]). When set, requires letsencrypt_name."
  type        = list(string)
  default     = []
}

variable "letsencrypt_name" {
  description = "Cert-manager ClusterIssuer name for ingress TLS. Required when ingress_hosts is set."
  type        = string
  default     = null
}

variable "ingress_username" {
  description = "Basic auth username for the push endpoint. When set with ingress_password, enables Basic auth."
  type        = string
  default     = null
}

variable "ingress_password" {
  description = "Basic auth password for the push endpoint."
  type        = string
  default     = null
  sensitive   = true
}
