resource "github_actions_secret" "kubeconfig" {
  for_each        = toset(var.repository_names)
  repository      = each.value
  secret_name     = "TF_KUBECONFIG_${replace(var.region_config.name, "-", "_")}"
  plaintext_value = var.kubeconfig
}
