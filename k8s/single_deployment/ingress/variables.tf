variable "name" {
  description = "Name used for Certificate and Ingress resources"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the Certificate and Ingress"
  type        = string
}

variable "hosts" {
  description = "Host names for TLS and ingress rules (e.g. [\"grafana.example.com\"])"
  type        = list(string)
}

variable "path_prefixes" {
  description = "List of path prefixes to allow (e.g. [\"/\"], [\"/api\", \"/ready\"])"
  type        = list(string)
  default     = ["/"]
}

variable "letsencrypt_name" {
  description = "Name of the cert-manager ClusterIssuer (e.g. letsencrypt dev/staging)"
  type        = string
}

variable "service_name" {
  description = "Name of the backend Kubernetes service"
  type        = string
}

variable "service_port" {
  description = "Target port number of the backend service"
  type        = number
  default     = 80
}

variable "labels" {
  description = "Labels to apply to Certificate and Ingress metadata"
  type        = map(string)
  default     = {}
}

# Optional basic auth (Traefik middleware). When both set, ingress requires Basic auth.
variable "username" {
  description = "Basic auth username. When set with password, enables Basic auth on the ingress."
  type        = string
  default     = null
}

variable "password" {
  description = "Basic auth password. When set with username, enables Basic auth on the ingress."
  type        = string
  default     = null
  sensitive   = true
}
