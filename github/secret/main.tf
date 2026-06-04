# Single GitHub Actions repository secret

resource "github_actions_secret" "this" {
  repository      = var.repository
  secret_name     = var.secret_name
  plaintext_value = var.plaintext_value
}
