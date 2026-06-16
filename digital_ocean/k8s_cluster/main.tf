data "digitalocean_kubernetes_versions" "versions" {}

resource "digitalocean_kubernetes_cluster" "main" {
  name    = "${var.region_config.name}-k8s"
  region  = var.region_config.location
  version = data.digitalocean_kubernetes_versions.versions.latest_version

  ha                               = var.high_availability
  destroy_all_associated_resources = true

  kubeconfig_expire_seconds = var.kubeconfig_expire_seconds

  # DO drives upgrades automatically: auto_upgrade applies new PATCH releases
  # during the maintenance window, and surge_upgrade brings up replacement
  # nodes before draining the old ones. The lifecycle.ignore_changes[version]
  # below is what keeps this safe: without it, a routine `terraform apply`
  # re-resolves latest_version and upgrades the cluster on the spot (that
  # apply-time bump recycled every AU node at 22:19 AEST on 2026-05-26).
  # Minor-version bumps stay manual via doctl, in a low-traffic window.
  auto_upgrade  = var.auto_upgrade
  surge_upgrade = true

  maintenance_policy {
    day        = var.maintenance_policy.day
    start_time = var.maintenance_policy.start_time
  }

  node_pool {
    name       = "${var.region_config.name}-worker-pool"
    size       = var.node_size
    node_count = var.node_count
  }

  # version is managed by DO (auto_upgrade) + manual doctl upgrades, NOT by
  # Terraform. Ignoring it prevents apply-time upgrades and drift fights.
  lifecycle {
    ignore_changes = [version]
  }
}
