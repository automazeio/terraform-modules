variable "namespace_name" {
  description = "Kubernetes namespace where the ServiceAccount and secret are created (e.g. app)."
  type        = string
}

variable "harbor_host" {
  description = "Harbor registry host for dockerconfigjson auth (e.g. harbor.example.com)."
  type        = string
}

variable "harbor_admin_password" {
  description = "Harbor admin password for image pull auth."
  type        = string
  sensitive   = true
}

variable "service_account_name" {
  description = "Name of the ServiceAccount and pull secret."
  type        = string
  default     = "harbor-pull"
}
