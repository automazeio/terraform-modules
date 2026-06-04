# Variables for Harbor setup (project creation via goharbor/harbor provider).
# Configure the Harbor provider in the calling module (url, username, password or env HARBOR_*).

variable "project_name" {
  description = "Name of the Harbor project to create"
  type        = string
}

variable "project_public" {
  description = "Whether the project is public (anyone can pull)"
  type        = bool
  default     = false
}

variable "vulnerability_scanning" {
  description = "Scan images for vulnerabilities on push"
  type        = bool
  default     = true
}

variable "enable_content_trust" {
  description = "Enable Content Trust (Notary) - deny unsigned images"
  type        = bool
  default     = false
}

variable "enable_content_trust_cosign" {
  description = "Enable Content Trust Cosign - deny images without Cosign signature"
  type        = bool
  default     = false
}

variable "auto_sbom_generation" {
  description = "Automatically generate SBOM for pushed images (Harbor v2.11+)"
  type        = bool
  default     = false
}

variable "storage_quota_gb" {
  description = "Storage quota for the project in GB (null = no quota)"
  type        = number
  default     = null
}

# Tag retention / auto-clean
variable "retention_keep_n" {
  description = "Keep only the N most recently pushed artifacts per repo; older ones are deleted. Set to null to disable retention policy."
  type        = number
  default     = 10
}

variable "retention_schedule" {
  description = "When to run the retention policy: Hourly, Daily, Weekly, or a cron expression"
  type        = string
  default     = "Daily"
}

# System-wide garbage collection. Retention only marks tags as deleted; GC purges
# the underlying blobs from registry storage. Without it, the registry PVC fills
# with orphaned blobs even when project quota looks fine.
variable "gc_schedule" {
  description = "When to run garbage collection: hourly, daily, weekly, or a cron expression (e.g. \"0 5 4 * * *\")"
  type        = string
  default     = "Daily"
}

variable "gc_delete_untagged" {
  description = "Also delete untagged artifacts during GC"
  type        = bool
  default     = true
}

variable "gc_workers" {
  description = "Number of GC workers (Harbor caps this internally)"
  type        = number
  default     = 1
}
