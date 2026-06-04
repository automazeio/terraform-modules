output "service_account_name" {
  description = "Name of the ServiceAccount to use for pods that pull from Harbor."
  value       = kubernetes_service_account_v1.harbor_pull.metadata[0].name
}
