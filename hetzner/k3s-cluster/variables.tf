# K8s Cluster Component Variables

variable "microos_x86_snapshot_id" {
  description = "Snapshot ID for MicroOS x86"
  type        = string
}

variable "microos_arm_snapshot_id" {
  description = "Snapshot ID for MicroOS ARM"
  type        = string
}

variable "region_config" {
  description = "Configuration for the region where the cluster will be deployed"
  type = object({
    name         = string
    location     = string
    network_zone = string
  })
}

variable "server_type" {
  description = "Server type for the nodes."
  type = object({
    master = string
    worker = string
  })
}

variable "autoscaler" {
  description = "Cluster autoscaler config. The cartesian product of `locations` x `types` generates one pool per combination, all sharing the peak-workloads label/taint so the autoscaler treats them as interchangeable and falls over between them when Hetzner stocks out a server type in a location. Leave both lists empty to disable."
  type = object({
    locations = optional(list(string), [])
    types     = optional(list(string), [])
    max_nodes = optional(number, 3)
  })
  default = {}
}

variable "high_availability" {
  description = "Whether to deploy a high availability control plane"
  type        = bool
  default     = false
}

variable "worker_count" {
  description = "Number of worker nodes to deploy"
  type        = number
  default     = 1
}

variable "ssh_keys" {
  description = "SSH keys from the ssh_keys component"
  type = object({
    master_ssh = object({
      public_key  = string
      private_key = string
    })
    worker_ssh = object({
      public_key  = string
      private_key = string
    })
  })
  sensitive = true
}

variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "enable_longhorn" {
  description = "Enable Longhorn distributed block storage in the cluster"
  type        = bool
  default     = true
}

variable "longhorn_replica_count" {
  description = "Default number of replicas for Longhorn volumes"
  type        = number
  default     = 2
}

variable "control_plane_hostname" {
  description = "Hostname pointed at all control-plane IPs (round-robin DNS). When set, replaces the control-plane LB: the apiserver cert gets this SAN and the kubeconfig points at this hostname. The hostname's DNS records are NOT created here — provision them separately against the control_planes_public_ipv4 output."
  type        = string
  default     = null
}

variable "maintenance_policy" {
  description = "Maintenance window for OS auto-update reboots. start_time is UTC HH:MM; window is 4 hours."
  type = object({
    day        = string
    start_time = string
  })
  default = {
    day        = "saturday"
    start_time = "00:00"
  }
}

variable "traefik_read_timeout" {
  description = "respondingTimeouts.readTimeout for the Traefik `web` and `websecure` entrypoints, as a Go duration string (e.g. \"30m\"). readTimeout caps the time to read the ENTIRE request including the body, so a low value resets slow/large uploads. Defaults to \"60s\" — RAISE it (e.g. \"30m\") on any entrypoint that must accept large/slow uploads. The `mongodb` entrypoint keeps its own 30m timeout regardless."
  type        = string
  default     = "60s"
  nullable    = false

  validation {
    condition     = can(regex("^([0-9]+(ns|us|ms|s|m|h))+$", var.traefik_read_timeout))
    error_message = "traefik_read_timeout must be a Go duration string such as \"60s\", \"5m\", or \"1h30m\"."
  }
}
