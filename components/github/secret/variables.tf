variable "repository" {
  description = "GitHub repository name (e.g. my-repo) or owner/repo (e.g. my-org/my-repo)"
  type        = string
}

variable "secret_name" {
  description = "Name of the GitHub Actions secret (e.g. HARBOR_USERNAME, TF_KUBECONFIG)"
  type        = string
}

variable "plaintext_value" {
  description = "Plaintext value for the secret (stored encrypted by GitHub)"
  type        = string
  sensitive   = true
}
