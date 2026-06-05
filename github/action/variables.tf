# Variables for GitHub Actions workflow (Build & Push to container registry, Deploy to cluster)

variable "branch" {
  description = "Branch to trigger the workflow on push"
  type        = string
  default     = "master"
}

variable "registry_host" {
  description = "Container registry host for Docker login and image push (e.g. ghcr.io, harbor.example.com — no scheme)"
  type        = string
}

variable "image_repository" {
  description = "Image repository path (e.g. owner/repo for GHCR, or project/image-name for Harbor)"
  type        = string
}

variable "dockerfile_path" {
  description = "Path to Dockerfile"
  type        = string
  default     = "./Dockerfile"
}

variable "context" {
  description = "Build context for docker/build-push-action"
  type        = string
  default     = "."
}

variable "build_args" {
  description = "Map of Docker build ARG name -> GitHub Actions secret name. Values are passed as secrets in the workflow (e.g. ARG_NAME = \"SECRET_NAME\")."
  type        = map(string)
  default     = {}
}

variable "build_args_literals" {
  description = "Map of Docker build ARG name -> literal value (e.g. NODE_ENV = \"development\"). Values are inlined in the workflow."
  type        = map(string)
  default     = {}
}

variable "deployment_names" {
  description = "Kubernetes deployment name(s) to update on deploy. Accepts a single string or list of strings."
  type        = list(string)
}

variable "namespace" {
  description = "Kubernetes namespace for the deployment"
  type        = string
  default     = "app"
}

# --- Configurable secret / env names (used in the workflow) ---

variable "registry_username_secret_name" {
  description = "Name of the GitHub Actions secret for container registry username"
  type        = string
  default     = "REGISTRY_USERNAME"
}

variable "registry_password_secret_name" {
  description = "Name of the GitHub Actions secret for container registry password"
  type        = string
  default     = "REGISTRY_PASSWORD"
}

variable "kubeconfig_secret_name" {
  description = "Name of the GitHub Actions secret containing the kubeconfig (e.g. TF_KUBECONFIG)"
  type        = string
  default     = "TF_KUBECONFIG"
}

variable "kubeconfig_env_var_name" {
  description = "Environment variable name for the kubeconfig file path in the deploy job (e.g. KUBECONFIG)"
  type        = string
  default     = "KUBECONFIG"
}

variable "kubeconfig_file_path" {
  description = "File path where kubeconfig is written in the deploy job (e.g. kubeconfig.yaml)"
  type        = string
  default     = "kubeconfig.yaml"
}

variable "repository" {
  description = "GitHub repository name (e.g. my-repo) or owner/repo (e.g. my-org/my-repo)"
  type        = string
}

variable "workflow_filename" {
  description = "Filename for the workflow file under .github/workflows/ (e.g. build-push-deploy.yml)"
  type        = string
  default     = "build-push-deploy.yml"
}

variable "commit_message" {
  description = "Commit message when creating or updating the workflow file"
  type        = string
  default     = "chore: update GitHub Actions workflow (Terraform)"
}

variable "commit_author" {
  description = "Commit author name. Set to null when using a GitHub App so GitHub can attribute the commit to the App."
  type        = string
  default     = "Terraform"
}

variable "commit_email" {
  description = "Commit author email. Set to null when using a GitHub App so GitHub can attribute the commit to the App."
  type        = string
  default     = "terraform@localhost"
}
