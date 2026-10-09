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

variable "retention" {
  description = "How long Prometheus keeps samples (Prometheus --storage.tsdb.retention.time)"
  type        = string
  default     = "7d"
}

variable "retention_size" {
  description = "Upper bound on TSDB size before the oldest blocks are dropped (e.g. \"18GB\"). Keep it below storage_size so the volume never fills. Null means no size limit."
  type        = string
  default     = null
}

variable "storage_size" {
  description = "Size of the PersistentVolumeClaim for the Prometheus TSDB (e.g. \"20Gi\"). Null keeps the chart default, an emptyDir that loses all metrics whenever the pod restarts."
  type        = string
  default     = null
}

variable "storage_class_name" {
  description = "StorageClass for the Prometheus PVC. Null uses the cluster default; set it explicitly on clusters with more than one default class."
  type        = string
  default     = null
}
