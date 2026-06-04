# Provider requirements for the k8s-clusters component

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.59"
    }
    # Fix for https://github.com/isometry/terraform-provider-deepmerge/issues/133
    # │ Error: Failed to install provider
    # │
    # │ Error while installing isometry/deepmerge v1.2.2: the provider is not signed with a valid signing key; please contact the provider author (error
    # │ checking signature: openpgp: invalid signature: RSA verification failure)
    deepmerge = {
      source  = "isometry/deepmerge"
      version = "1.2.1"
    }
  }
}
