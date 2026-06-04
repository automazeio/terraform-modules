# K8s Configuration Component Variables

variable "cluster_ipv4" {
  description = "The IPv4 address of the cluster"
  type        = string
}

variable "cluster_ipv6" {
  description = "The IPv6 address of the cluster"
  type        = string
  default     = null
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare zone ID for the managed domain"
  type        = string
}

variable "domain_name" {
  description = "Base domain name for ingress resources"
  type        = string
}

variable "subdomain_name" {
  description = "Subdomain name for the services (e.g., 'api' for api.example.com)"
  type        = string
}

variable "ttl" {
  description = "DNS record TTL in seconds. Lower values speed up failover when an IP becomes unreachable; useful for round-robin records over multiple backends."
  type        = number
  default     = 300
}

