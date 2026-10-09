# Variables for Redis Helm deployment

variable "namespace_name" {
  description = "Kubernetes namespace where Redis will be deployed"
  type        = string
}

variable "storage_class_name" {
  description = "StorageClass for the Redis PVC. Leave null to use the cluster default."
  type        = string
  default     = null
}

variable "storage_size" {
  description = "Override PVC size for Redis persistence (e.g. \"2Gi\"). Leave null to use the computed ceil(max_memory*1.5)Mi."
  type        = string
  default     = null
}

variable "persistence_enabled" {
  description = "Whether to enable persistence for Redis."
  type        = bool
  default     = true
}

variable "max_memory" {
  description = "Maximum memory (in Mi) for each Redis pod."
  type        = number
  default     = 800
}

variable "maxmemory_policy" {
  description = "Eviction policy applied when Redis reaches maxmemory (Redis --maxmemory-policy)."
  type        = string
  default     = "allkeys-lru"
}

variable "auth_enabled" {
  type    = bool
  default = false
}

variable "release_name" {
  description = "Helm release name. Also prefixes the Services (`<release_name>-master`), so two releases can run side by side in one namespace during a migration."
  type        = string
  default     = "redis"
}

variable "sentinel_enabled" {
  description = "Run Redis as a replicated set with Sentinel failover instead of a single standalone pod. Clients still connect to `<release_name>-master`, which follows the current master."
  type        = bool
  default     = false
}

variable "replica_count" {
  description = "Number of Redis pods (each with its own Sentinel) when sentinel_enabled. Keep it at 3 or more so Sentinel keeps a quorum of 2 while one node is down."
  type        = number
  default     = 3

  validation {
    condition     = var.replica_count >= 3
    error_message = "replica_count must be at least 3 for a Sentinel quorum of 2."
  }
}

variable "pod_anti_affinity_preset" {
  description = "Anti-affinity between Redis pods when sentinel_enabled (\"hard\" or \"soft\"). \"hard\" guarantees one node reboot never takes down more than one pod, but needs at least replica_count schedulable nodes."
  type        = string
  default     = "hard"

  validation {
    condition     = contains(["hard", "soft"], var.pod_anti_affinity_preset)
    error_message = "pod_anti_affinity_preset must be \"hard\" or \"soft\"."
  }
}

variable "sentinel_down_after_milliseconds" {
  description = "How long the master must be unreachable before Sentinel starts a failover. Only applies to unplanned loss; drains and rollouts fail over immediately from the pod's preStop hook."
  type        = number
  default     = 10000
}

variable "connection_host" {
  description = "Host used in the connection_string output. Defaults to the release's master Service; override to route clients through another Service (for example while migrating data between releases)."
  type        = string
  default     = null
}
