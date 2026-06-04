# Variables for Harbor Helm deployment

variable "namespace_name" {
  description = "Kubernetes namespace where Harbor will be deployed"
  type        = string
}

variable "external_url" {
  description = "External URL for Harbor (e.g. https://harbor.example.com)"
  type        = string
}

variable "expose_type" {
  description = "How to expose Harbor: ingress, clusterIP, nodePort, or loadBalancer"
  type        = string
  default     = "clusterIP"
}

variable "harbor_admin_password" {
  description = "Initial admin password. If null, a random password is generated (stored in Kubernetes secret)"
  type        = string
  default     = null
  sensitive   = true
}

variable "chart_version" {
  description = "Harbor Helm chart version"
  type        = string
  default     = "1.18.2"
}

variable "ingress_host" {
  description = "Ingress hostname for core service (required when expose_type is ingress)"
  type        = string
  default     = null
}

variable "ingress_tls_secret" {
  description = "Name of the TLS secret for Ingress (optional when expose_type is ingress)"
  type        = string
  default     = "harbor-tls"
}

variable "ingress_class_name" {
  description = "Kubernetes IngressClass name (e.g. traefik, nginx). Used when expose_type is ingress."
  type        = string
  default     = "traefik"
}

variable "ingress_annotations" {
  description = "Annotations for the Ingress (e.g. for Traefik). Merged with defaults when expose_type is ingress."
  type        = map(string)
  default     = {}
}

variable "persistence_enabled" {
  description = "Enable persistent storage for registry and database"
  type        = bool
  default     = true
}

variable "registry_storage_size" {
  description = "Size of the registry PVC (e.g. 30Gi)"
  type        = string
  default     = "30Gi"
}

variable "database_storage_size" {
  description = "Size of the database PVC (e.g. 1Gi)"
  type        = string
  default     = "1Gi"
}

variable "service_account_name" {
  description = "Kubernetes ServiceAccount name for Harbor components. When set, this SA is used (must exist in the same namespace). When null, a ServiceAccount is created in this module and used."
  type        = string
  default     = null
}

variable "service_account_name_created" {
  description = "Name of the ServiceAccount created by this module when service_account_name is null."
  type        = string
  default     = "registry"
}

variable "certificate_issuer_name" {
  description = "Name of the cert-manager ClusterIssuer/Issuer for TLS. When set, a Certificate is created with secretName = ingress_tls_secret."
  type        = string
  default     = null
}

variable "certificate_issuer_kind" {
  description = "Kind of the cert-manager issuer (ClusterIssuer or Issuer)."
  type        = string
  default     = "ClusterIssuer"
}
