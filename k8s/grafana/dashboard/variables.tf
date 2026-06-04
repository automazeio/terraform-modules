# Variables for Grafana (dashboard) Helm deployment (grafana-community chart)

variable "namespace_name" {
  description = "Kubernetes namespace where Grafana will be deployed"
  type        = string
}

variable "chart_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "11.3.0"
}

variable "admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "admin_existing_secret_name" {
  description = "Name of existing secret with keys admin-user and admin-password. If set, admin_password is ignored."
  type        = string
  default     = null
}

variable "admin_password" {
  description = "Grafana admin password (used when admin_existing_secret_name is not set)"
  type        = string
  default     = null
  sensitive   = true
}

variable "replicas" {
  description = "Number of Grafana replicas"
  type        = number
  default     = 1
}

variable "datasources" {
  description = "Map of datasource config names to YAML content for provisioning (see chart datasources)"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "Extra environment variables for the Grafana deployment"
  type        = map(string)
  default     = {}
}

# Optional ingress (TLS + Traefik). Omit or set to empty to skip.
variable "ingress_hosts" {
  description = "Host names for TLS and ingress (e.g. [\"grafana.example.com\"]). When non-empty, ingress is created; requires letsencrypt_name."
  type        = list(string)
  default     = []
}

variable "letsencrypt_name" {
  description = "Name of the cert-manager ClusterIssuer for ingress TLS. Required when ingress_hosts is set."
  type        = string
  default     = null
}
