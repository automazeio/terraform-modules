output "certificate_secret_name" {
  description = "Name of the TLS secret created by the Certificate"
  value       = "${var.name}-certificate-tls"
}

output "ingress_name" {
  description = "Name of the created Ingress resource"
  value       = kubernetes_ingress_v1.ingress.metadata[0].name
}
