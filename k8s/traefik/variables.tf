variable "agent_count" {
  type        = number
  description = "Number of agent (worker) nodes in the cluster."
}

variable "traefik_read_timeout" {
  description = "respondingTimeouts.readTimeout for the Traefik `web` and `websecure` entrypoints, as a Go duration string (e.g. \"30m\"). readTimeout caps the time to read the ENTIRE request including the body, so a low value resets slow/large uploads. Defaults to \"60s\" — RAISE it (e.g. \"30m\") on any entrypoint that must accept large/slow uploads."
  type        = string
  default     = "60s"
  nullable    = false

  validation {
    condition     = can(regex("^([0-9]+(ns|us|ms|s|m|h))+$", var.traefik_read_timeout))
    error_message = "traefik_read_timeout must be a Go duration string such as \"60s\", \"5m\", or \"1h30m\"."
  }
}
