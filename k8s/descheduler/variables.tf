variable "namespace_name" {
  description = "Kubernetes namespace for descheduler"
  type        = string
  default     = "kube-system"
}

variable "chart_version" {
  description = "descheduler Helm chart version"
  type        = string
  default     = "0.35.1"
}

variable "create_namespace" {
  description = "Create the namespace if it does not exist"
  type        = bool
  default     = false
}

variable "schedule" {
  description = "Cron schedule for the descheduler CronJob."
  type        = string
  default     = "0 * * * *"
}

variable "max_no_of_pods_to_evict_per_node" {
  description = "Max pods the descheduler may evict per node in a single run. Bounds churn on small clusters and makes the balance-plugin order act as a priority — a scarce eviction budget is spent on the first-listed plugin first."
  type        = number
  default     = 1
}

variable "low_node_utilization_thresholds" {
  description = "Underutilization thresholds (percent). Nodes below these are eviction targets."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 50
    memory = 70
  }
}

variable "low_node_utilization_target_thresholds" {
  description = "Overutilization thresholds (percent). Nodes above these have pods evicted."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 80
    memory = 88
  }
}
