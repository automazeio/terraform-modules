output "secret_name" {
  description = "Name of the GitHub Actions secret"
  value       = github_actions_secret.this.secret_name
}
