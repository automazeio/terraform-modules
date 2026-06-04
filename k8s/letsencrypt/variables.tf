variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt registration and recovery"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "dns01_provider" {
  description = "DNS-01 provider to use for cert-manager"
  type = object({
    name      = string
    api_token = string
    dns_zones = list(string)
  })
  nullable = true
}
