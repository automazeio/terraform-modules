variable "namespace_name" {
  description = "Kubernetes namespace for Databasus (e.g. databasus)"
  type        = string
}

variable "chart_version" {
  description = "Databasus Helm chart version (OCI). Check https://github.com/databasus/databasus/releases for chart versions."
  type        = string
  default     = "3.32.0"
}

variable "create_namespace" {
  description = "Create the namespace if it does not exist"
  type        = bool
  default     = true
}

variable "ingress_hosts" {
  description = "Host names for Databasus UI ingress (e.g. [\"backup.example.com\"]). When set, requires letsencrypt_name."
  type        = list(string)
  default     = []
}

variable "letsencrypt_name" {
  description = "Cert-manager ClusterIssuer name for ingress TLS. Required when ingress_hosts is set."
  type        = string
  default     = null
}

variable "persistence_storage_class" {
  description = "Storage class for the persistent volume (e.g. hcloud-volumes, longhorn)."
  type        = string
  default     = ""
}

variable "persistence_size" {
  description = "Size of the persistent volume claim."
  type        = string
  default     = "10Gi"
}
