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
  description = "The maximum resources for the container (the container LIMITS). The REQUESTS are derived as request_to_limit_ratio * these values."
  type = object({
    cpu    = number
    memory = number
  })
  nullable = true
}

variable "cpu_request_ratio" {
  description = "Fraction of the CPU LIMIT (max_resources.cpu) used as the CPU REQUEST. Default 0.5 (request = half the limit = 2x burst headroom). The CPU request is the HPA's denominator and the scheduling/shares reservation: raise it to lift the scale-up threshold (request x cpu utilization target) above your real peak, but keep it < 1 so the container keeps burst headroom before CFS throttling."
  type        = number
  default     = 0.5
  validation {
    condition     = var.cpu_request_ratio > 0 && var.cpu_request_ratio <= 1
    error_message = "cpu_request_ratio must be in (0, 1]."
  }
}

variable "memory_request_ratio" {
  description = "Fraction of the memory LIMIT (max_resources.memory) used as the memory REQUEST. Default 0.5. Memory is non-compressible (exceeding the LIMIT is an OOMKill, not throttling), so size the request to the real working set plus headroom. Independent of cpu_request_ratio because memory and CPU size differently."
  type        = number
  default     = 0.5
  validation {
    condition     = var.memory_request_ratio > 0 && var.memory_request_ratio <= 1
    error_message = "memory_request_ratio must be in (0, 1]."
  }
}

variable "health_check_path" {
  description = "The path for the health check."
  type        = string
  nullable    = true
}

variable "startup_probe" {
  description = "The startup probe for the container; gates the whole boot and uses the deep `health_check_path`. `timeout_seconds` defaults to 1 (the Kubernetes default) — raise it for heavy apps whose health endpoint can take >1s under load, otherwise a slow-but-healthy boot is killed as a false startup failure."
  type = object({
    initial_delay_seconds = number
    period_seconds        = number
    failure_threshold     = number
    timeout_seconds       = optional(number, 1)
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

variable "pre_stop_sleep_seconds" {
  description = "If set, adds a container preStop hook that sleeps this many seconds before the container receives SIGTERM. Bridges the window between the pod leaving the Service endpoints and the process stopping, so the proxy (Traefik) finishes draining in-flight requests instead of returning 502 during scale-down/rollout. Must be less than termination_grace_period_seconds. Null disables the hook."
  type        = number
  default     = null
  nullable    = true
}

variable "termination_grace_period_seconds" {
  description = "Pod terminationGracePeriodSeconds. Must exceed pre_stop_sleep_seconds plus the app's in-flight drain time, or the kubelet SIGKILLs the pod mid-drain. Null leaves the Kubernetes default (30)."
  type        = number
  default     = null
  nullable    = true
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
  description = "Replica bounds for the HPA, plus scale stabilization windows. `scale_up_stabilization_seconds` defaults to 60: the HPA must see the load persist ~60s before adding a pod, which stops 2<->3 replica flapping (and the 502s each scale-down can cause). Set it to null to fall back to the Kubernetes default (0s = scale up on any momentary spike)."
  type = object({
    min_replicas                     = number
    max_replicas                     = number
    scale_up_stabilization_seconds   = optional(number, 60)
    scale_down_stabilization_seconds = optional(number, 300)
  })
  default = {
    min_replicas = 1
    max_replicas = 1
  }
}

variable "horizontal_pod_autoscaler_cpu_utilization_percentage" {
  description = "Target average CPU utilization % for the HPA. The primary scaling signal."
  type        = number
  default     = 70
  nullable    = false
}

variable "horizontal_pod_autoscaler_memory_utilization_percentage" {
  description = "Target average MEMORY utilization % for the HPA. Set it HIGHER than the CPU target so CPU stays the primary scaler and memory acts as a safety net for memory pressure. IMPORTANT: size memory_request_ratio so normal usage sits comfortably below this target — because per-pod memory does not fall when replicas are added, a memory metric that is chronically over target ratchets the deployment to max_replicas and never scales back."
  type        = number
  default     = 80
  nullable    = false
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
