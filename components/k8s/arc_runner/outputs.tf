output "controller_namespace" {
  description = "Namespace where the ARC controller is running"
  value       = var.controller_namespace
}

output "runner_namespace" {
  description = "Namespace where runner pods are created"
  value       = var.runner_namespace
}

output "installation_name" {
  description = "Runner scale set name; use this as runs-on in workflows"
  value       = var.installation_name
}
