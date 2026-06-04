# Cloudflare DNS Records Configuration

resource "cloudflare_dns_record" "wildcard_ipv4" {
  zone_id = var.cloudflare_zone_id
  name    = "${var.subdomain_name}.${var.domain_name}"
  content = var.cluster_ipv4
  type    = "A"
  ttl     = var.ttl
  proxied = false
  comment = "Wildcard A record pointing to K8s master node"
}

resource "cloudflare_dns_record" "wildcard_ipv6" {
  count = var.cluster_ipv6 != null ? 1 : 0

  zone_id = var.cloudflare_zone_id
  name    = "${var.subdomain_name}.${var.domain_name}"
  content = var.cluster_ipv6
  type    = "AAAA"
  ttl     = var.ttl
  proxied = false
  comment = "Wildcard AAAA record pointing to K8s master node"
}
