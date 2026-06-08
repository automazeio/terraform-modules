variable "namespace" {
  description = "The namespace for the single deployment."
  type        = string
}

variable "name" {
  description = "The name of the single deployment."
  type        = string
}

variable "letsencrypt_name" {
  description = "The name of the Let's Encrypt issuer."
  type        = string
}

variable "hosts" {
  description = "The hosts for the Let's Encrypt certificate."
  type        = list(string)
}

variable "path_prefix" {
  description = "The path prefix for the Let's Encrypt certificate."
  type        = string
  default     = "/"
}

variable "config_map_data" {
  description = "The data for the config map."
  type        = map(string)
  default     = {}
}

variable "secret_data" {
  description = "The data for the secret."
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "The timeouts for the single deployment."
  type = object({
    create = string
    update = string
    delete = string
  })
  default = {
    create = "2m"
    update = "2m"
    delete = "2m"
  }
}

variable "container_image" {
  description = "The container image for the single deployment."
  type        = string
}

variable "container_port" {
  description = "The port for the container."
  type        = number
  default     = 3000
}

variable "max_resources" {
  description = "The maximum resources for the container."
  type = object({
    cpu    = number
    memory = number
  })
  nullable = true
}

variable "health_check_path" {
  description = "The path for the health check."
  type        = string
  nullable    = true
}

variable "startup_probe" {
  description = "The startup probe for the container."
  type = object({
    initial_delay_seconds = number
    period_seconds        = number
    failure_threshold     = number
  })
  nullable = true
}

variable "readiness_probe" {
  description = "Readiness probe. A failure removes the pod from the Service (no restart). Point `path` at a SHALLOW endpoint: a deep check against a SHARED dependency (e.g. the DB) fails every pod at once and depools the whole service. Null to disable."
  type = object({
    path              = string
    period_seconds    = number
    timeout_seconds   = number
    failure_threshold = number
  })
  default  = null
  nullable = true
}

variable "liveness_probe" {
  description = "Liveness probe. A failure RESTARTS the container, so `path` MUST be a shallow endpoint that does not check external deps (DB/redis) — otherwise a dependency blip restarts every pod at once. Keep it lenient (high failure_threshold). Null to disable."
  type = object({
    path                  = string
    initial_delay_seconds = number
    period_seconds        = number
    timeout_seconds       = number
    failure_threshold     = number
  })
  default  = null
  nullable = true
}

variable "service_account_name" {
  description = "The name of the service account for the deployment."
  type        = string
  default     = ""
}

variable "extra_volume_mounts" {
  description = "Extra volume mounts for the container."
  type = list(object({
    name       = string
    mount_path = string
    sub_path   = optional(string)
    read_only  = optional(bool, true)
  }))
  default = []
}

variable "extra_volumes" {
  description = "Extra volumes for the pod (config_map sources)."
  type = list(object({
    name            = string
    config_map_name = string
  }))
  default = []
}

variable "horizontal_pod_autoscaler" {
  description = "The horizontal pod autoscaler for the deployment."
  type = object({
    min_replicas                  = number
    max_replicas                  = number
    cpu_utilization_percentage    = number
    memory_utilization_percentage = number
  })
  default = {
    min_replicas                  = 1
    max_replicas                  = 1
    cpu_utilization_percentage    = 70
    memory_utilization_percentage = 80
  }
}

variable "prefer_non_control_plane" {
  description = "When true, adds a soft (preferred) nodeAffinity steering pods toward non-control-plane (worker) nodes. It's a preference, not a requirement — pods still land on control-plane nodes if workers lack capacity (never Pending). No-op on clusters whose nodes carry no control-plane label (e.g. managed DOKS)."
  type        = bool
  default     = true
}

variable "node_auto_config" {
  description = "Node.js images only. When true (and max_resources is set), the module appends NODE_OPTIONS=--max-old-space-size so V8 always has a heap ceiling below the container memory limit. This prevents the classic container OOMKill: Node sizes its default heap from HOST RAM, not the cgroup limit, so an uncapped process can grow past the limit and be killed before V8 garbage-collects. Leave false for non-Node images."
  type        = bool
  default     = false
}

variable "node_max_old_space_size_ratio" {
  description = "Fraction of the memory limit V8's old-space may use; applied only when node_auto_config = true. Default 0.75 suits heap-dominant apps (API, SSR web). Use a LOW value for processes whose memory is dominated by OFF-HEAP children the flag cannot see (e.g. a Puppeteer/Chromium worker → ~0.2), leaving the rest of the limit for those children."
  type        = number
  default     = 0.75
  validation {
    condition     = var.node_max_old_space_size_ratio > 0 && var.node_max_old_space_size_ratio < 1
    error_message = "node_max_old_space_size_ratio must be in (0, 1) exclusive; a ratio >= 1 would put the heap cap at or above the container memory limit and guarantee an OOMKill."
  }
}
