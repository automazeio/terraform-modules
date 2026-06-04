# Harbor provider is configured via variables passed to the module caller.
# Caller must configure provider "harbor" with url, username, password (or use env HARBOR_URL, HARBOR_USERNAME, HARBOR_PASSWORD).

resource "harbor_project" "main" {
  name                        = var.project_name
  public                      = var.project_public
  vulnerability_scanning      = var.vulnerability_scanning
  enable_content_trust        = var.enable_content_trust
  enable_content_trust_cosign = var.enable_content_trust_cosign
  auto_sbom_generation        = var.auto_sbom_generation
  storage_quota               = var.storage_quota_gb
}

# Retain only the N most recently pushed artifacts per repo; older ones are deleted on schedule.
resource "harbor_retention_policy" "main" {
  count = var.retention_keep_n != null && var.retention_keep_n > 0 ? 1 : 0

  scope    = harbor_project.main.id
  schedule = var.retention_schedule

  rule {
    most_recently_pushed = var.retention_keep_n
    repo_matching        = "**"
    tag_matching         = "**"
  }
}

# System-wide GC: purges blobs left behind by retention deletions and removes
# incomplete uploads. Without this the registry PVC fills with orphans.
resource "harbor_garbage_collection" "main" {
  schedule        = var.gc_schedule
  delete_untagged = var.gc_delete_untagged
  workers         = var.gc_workers
}
