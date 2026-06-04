variable "namespace_name" {
  description = "Kubernetes namespace for kube-state-metrics"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "kube-state-metrics Helm chart version"
  type        = string
  default     = "5.30.1"
}

variable "create_namespace" {
  description = "Create the namespace if it does not exist"
  type        = bool
  default     = true
}
