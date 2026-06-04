output "release_name" {
  description = "Helm release name for kube-prometheus-stack"
  value       = helm_release.kube_prometheus_stack.name
}

output "release_namespace" {
  description = "Namespace where kube-prometheus-stack is deployed"
  value       = helm_release.kube_prometheus_stack.namespace
}

output "cluster_url" {
  description = "Cluster-internal base URL for the Prometheus service."
  value       = "http://${helm_release.kube_prometheus_stack.name}-prometheus.${helm_release.kube_prometheus_stack.namespace}.svc.cluster.local:9090"
}

output "cluster_remote_write_url" {
  description = "Cluster-internal URL for the Prometheus remote-write API."
  value       = "http://${helm_release.kube_prometheus_stack.name}-prometheus.${helm_release.kube_prometheus_stack.namespace}.svc.cluster.local:9090/api/v1/write"
}
