locals {
  environments = {
    prod = {
      name   = "letsencrypt-prod"
      server = "https://acme-v02.api.letsencrypt.org/directory"
    }
    dev = {
      name   = "letsencrypt-dev"
      server = "https://acme-staging-v02.api.letsencrypt.org/directory"
    }
  }
}
