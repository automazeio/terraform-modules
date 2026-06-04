variable "namespace_name" {
  description = "Kubernetes namespace for kube-prometheus-stack (e.g. monitoring)"
  type        = string
}

variable "chart_version" {
  description = "kube-prometheus-stack Helm chart version"
  type        = string
  default     = "82.9.0"
}

variable "create_namespace" {
  description = "Create the namespace if it does not exist"
  type        = bool
  default     = true
}
