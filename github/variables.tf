variable "kubeconfig" {
  description = "Kubeconfig content"
  type        = string
  sensitive   = true
}

variable "repository_names" {
  description = "GitHub repository name"
  type        = list(string)
}

variable "region_config" {
  description = "Configuration for the region where the cluster deployed"
  type = object({
    name = string
  })
}
