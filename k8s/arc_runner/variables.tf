variable "controller_namespace" {
  description = "Kubernetes namespace for the ARC controller (operator pods)"
  type        = string
  default     = "arc-systems"
}

variable "runner_namespace" {
  description = "Kubernetes namespace where runner pods will be created"
  type        = string
  default     = "arc-runners"
}

variable "installation_name" {
  description = "Name of the runner scale set; used as runs-on value in workflows"
  type        = string
}

variable "github_config_url" {
  description = "GitHub URL for the repo, org, or enterprise the runners belong to (e.g. https://github.com/my-org/my-repo)"
  type        = string
}

variable "github_token" {
  description = "GitHub PAT or token for authenticating with the GitHub API"
  type        = string
  sensitive   = true
}

variable "min_runners" {
  description = "Minimum number of idle runners to keep"
  type        = number
  default     = 0
}

variable "max_runners" {
  description = "Maximum number of runners the scale set can scale up to (0 = unbounded)"
  type        = number
  default     = 5
}

variable "runner_cpu_limit" {
  description = "CPU limit for runner pod containers in millicores (e.g. 1000 = 1 CPU). Applied via pod template when enable_dind is false, via namespace LimitRange when enable_dind is true."
  type        = number
  default     = null
}

variable "runner_memory_limit" {
  description = "Memory limit for runner pod containers in Mi (e.g. 2048 = 2Gi). Applied via pod template when enable_dind is false, via namespace LimitRange when enable_dind is true."
  type        = number
  default     = null
}

variable "runner_cpu_request" {
  description = "CPU request for runner pod containers in millicores. Defaults to runner_cpu_limit when null (guaranteed QoS); set lower for burstable QoS."
  type        = number
  default     = null
}

variable "enable_dind" {
  description = "Enable Docker-in-Docker in the runner pod so jobs can use Docker without a service container."
  type        = bool
  default     = false
}

variable "controller_chart_version" {
  description = "Helm chart version for gha-runner-scale-set-controller"
  type        = string
  default     = "0.13.1"
}

variable "runner_chart_version" {
  description = "Helm chart version for gha-runner-scale-set"
  type        = string
  default     = "0.13.1"
}

variable "runner_image" {
  description = "Image for the runner pod"
  type        = string
  default     = "ghcr.io/actions/actions-runner:latest"
}

variable "tolerate_peak_workloads" {
  description = "If true, runner pods tolerate the peak-workloads taint so they can land on the autoscaled nodepool."
  type        = bool
  default     = false
}