locals {
  ingress = data.kubernetes_service_v1.traefik.status[0].load_balancer[0].ingress
  ips     = [for i in local.ingress : i.ip if i.ip != null]
  ipv4    = try(one([for ip in local.ips : ip if !can(regex(":", ip))]), null)
  ipv6    = try(one([for ip in local.ips : ip if can(regex(":", ip))]), null)
}

output "load_balancer_ipv4" {
  value = local.ipv4

  precondition {
    condition     = local.ipv4 != null
    error_message = "Traefik LoadBalancer has no IPv4 address."
  }
}

output "load_balancer_ipv6" {
  value = local.ipv6
}
