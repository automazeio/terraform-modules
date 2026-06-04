output "name" {
  value = digitalocean_kubernetes_cluster.main.name
}

output "host" {
  value = digitalocean_kubernetes_cluster.main.endpoint
}

output "token" {
  value = digitalocean_kubernetes_cluster.main.kube_config[0].token
}

output "client_certificate" {
  value = base64decode(
    digitalocean_kubernetes_cluster.main.kube_config[0].client_certificate
  )
}

output "cluster_ca_certificate" {
  value = base64decode(
    digitalocean_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate
  )
}

output "client_key" {
  value = base64decode(
    digitalocean_kubernetes_cluster.main.kube_config[0].client_key
  )
}

output "kubeconfig" {
  value = digitalocean_kubernetes_cluster.main.kube_config[0].raw_config
}

output "ipv4_address" {
  value = digitalocean_kubernetes_cluster.main.ipv4_address
}