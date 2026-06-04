variable "name" {
  description = "Name used for Certificate and IngressRouteTCP resources"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "hosts" {
  description = "Host names for TLS and SNI routing"
  type        = list(string)
}

variable "letsencrypt_name" {
  description = "Name of the cert-manager ClusterIssuer"
  type        = string
}

variable "service_name" {
  description = "Name of the backend Kubernetes service"
  type        = string
}

variable "service_port" {
  description = "Target port number of the backend service"
  type        = number
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "entrypoint" {
  description = "Traefik entrypoint name"
  type        = string
  default     = "websecure"
}

