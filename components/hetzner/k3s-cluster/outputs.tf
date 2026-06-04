# K8s Cluster Component Outputs

locals {
  master_ipv4  = module.kube-hetzner.ingress_public_ipv4
  master_ipv6  = module.kube-hetzner.ingress_public_ipv6
  worker_ips   = module.kube-hetzner.agents_public_ipv4
  worker_count = length(module.kube-hetzner.agents_public_ipv4)
}

output "ingress_public" {
  description = "Public IP address for ingress traffic (load balancer or first control plane)"
  value = {
    ipv4 = module.kube-hetzner.ingress_public_ipv4
    ipv6 = module.kube-hetzner.ingress_public_ipv6
  }
}

output "master_ipv4" {
  description = "Public IPv4 address of the master node"
  value       = local.master_ipv4
}

output "master_ipv6" {
  description = "Public IPv6 address of the master node"
  value       = local.master_ipv6
}

output "worker_ips" {
  description = "Public IPv4 addresses of the worker nodes"
  value       = local.worker_ips
}

output "worker_count" {
  description = "Number of worker nodes deployed"
  value       = local.worker_count
}

output "cluster_summary" {
  description = "Summary of the deployed cluster"
  value = {
    master_ip    = local.master_ipv4
    worker_ips   = local.worker_ips
    worker_count = local.worker_count
  }
}

output "kubeconfig" {
  description = "Kubeconfig content with the correct server URL"
  value       = module.kube-hetzner.kubeconfig
  sensitive   = true
}

output "host" {
  description = "Kubernetes API server endpoint"
  value       = module.kube-hetzner.kubeconfig_data.host
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate"
  value       = module.kube-hetzner.kubeconfig_data.cluster_ca_certificate
  sensitive   = true
}

output "client_certificate" {
  description = "Kubernetes client certificate"
  value       = module.kube-hetzner.kubeconfig_data.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Kubernetes client key"
  value       = module.kube-hetzner.kubeconfig_data.client_key
  sensitive   = true
}

output "control_planes_public_ipv4" {
  description = "Public IPv4 addresses of all control-plane nodes (use to back round-robin DNS for the control plane)"
  value       = module.kube-hetzner.control_planes_public_ipv4
}

output "control_planes_public_ipv6" {
  description = "Public IPv6 addresses of all control-plane nodes"
  value       = module.kube-hetzner.control_planes_public_ipv6
}

# Load Balancer specific outputs
output "ingress_public_ipv4" {
  description = "Public IPv4 address for ingress traffic (load balancer or first control plane)"
  value       = module.kube-hetzner.ingress_public_ipv4
}

output "ingress_public_ipv6" {
  description = "Public IPv6 address for ingress traffic (load balancer or first control plane)"
  value       = module.kube-hetzner.ingress_public_ipv6
}

output "lb_control_plane_ipv4" {
  description = "Public IPv4 address of the Hetzner control plane load balancer"
  value       = module.kube-hetzner.lb_control_plane_ipv4
}

output "lb_control_plane_ipv6" {
  description = "Public IPv6 address of the Hetzner control plane load balancer"
  value       = module.kube-hetzner.lb_control_plane_ipv6
}
