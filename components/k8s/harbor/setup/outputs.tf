output "project_id" {
  description = "Harbor project ID"
  value       = harbor_project.main.project_id
}

output "project_name" {
  description = "Harbor project name"
  value       = harbor_project.main.name
}
