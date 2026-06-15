# Variables for GitHub Actions workflow (Build & Push to container registry, Deploy to cluster)

variable "branch" {
  description = "Branch to trigger the workflow on push"
  type        = string
  default     = "master"
}

variable "registry_host" {
  description = "Container registry host for Docker login and image push (e.g. ghcr.io, harbor.example.com — no scheme). Required when registry_type = \"password\"; unused for \"ecr\"."
  type        = string
  default     = null
}

variable "registry_type" {
  description = "Container registry auth mode: \"password\" (docker/login-action with username/password) or \"ecr\" (AWS credentials + amazon-ecr-login)."
  type        = string
  default     = "password"

  validation {
    condition     = contains(["password", "ecr"], var.registry_type)
    error_message = "registry_type must be either \"password\" or \"ecr\"."
  }
}

variable "image_repository" {
  description = "Image repository path (e.g. owner/repo for GHCR, or project/image-name for Harbor). Combined with registry_host to form the image reference. Ignored when image_uri is set."
  type        = string
  default     = null
}

variable "image_uri" {
  description = "Full image reference base, overriding registry_host/image_repository. May contain GitHub Actions expressions (e.g. an ECR URI kept in a repo variable) instead of a committed host/path."
  type        = string
  default     = null
}

variable "image_tag_sha_prefix" {
  description = "Prefix prepended to the short commit SHA in the immutable image tag (e.g. \"msb-api-main-\" yields \"msb-api-main-<sha>\"). Empty for a bare \"<sha>\" tag."
  type        = string
  default     = ""
}

variable "latest_tag" {
  description = "Mutable convenience tag pushed alongside the SHA-pinned tag (e.g. \"latest\", \"api-latest\")."
  type        = string
  default     = "latest"
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

variable "clusters" {
  description = "Clusters to deploy to. Each entry adds a value to the deploy matrix's cluster dimension and reads its kubeconfig from the named GitHub Actions secret. When empty, a single cluster is derived from kubeconfig_secret_name (preserving the single-cluster behavior)."
  type = list(object({
    name                   = string
    kubeconfig_secret_name = string
  }))
  default = []
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

variable "aws_region" {
  description = "AWS region for ECR login. Required when registry_type = \"ecr\"."
  type        = string
  default     = null
}

variable "aws_access_key_id_secret_name" {
  description = "GitHub Actions secret name holding the AWS access key id (registry_type = \"ecr\")."
  type        = string
  default     = "AWS_ACCESS_KEY_ID"
}

variable "aws_secret_access_key_secret_name" {
  description = "GitHub Actions secret name holding the AWS secret access key (registry_type = \"ecr\")."
  type        = string
  default     = "AWS_SECRET_ACCESS_KEY"
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

variable "cancel_in_progress" {
  description = "Whether a new run cancels an in-progress run in the same concurrency group. Good for dev/stage; set false for prod multi-cluster rollouts to avoid cancelling a partial rollout."
  type        = bool
  default     = true
}

variable "checkout_fetch_depth" {
  description = "fetch-depth for actions/checkout. null omits it (shallow clone). Set 0 to fetch full history."
  type        = number
  default     = null
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
