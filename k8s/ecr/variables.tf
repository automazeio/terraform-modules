variable "aws_account_id" {
  description = "AWS account ID that owns the ECR repository"
  type        = string
}

variable "aws_region" {
  description = "AWS region for ECR"
  type        = string
  default     = "eu-west-2"
}

variable "ecr_access_key_id" {
  description = "AWS Access Key ID for ECR authentication"
  type        = string
  sensitive   = true
}

variable "ecr_secret_access_key" {
  description = "AWS Secret Access Key for ECR authentication"
  type        = string
  sensitive   = true
}

variable "namespace_name" {
  description = "Kubernetes namespace name where ECR resources will be created"
  type        = string
}
