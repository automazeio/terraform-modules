output "certificate_secret_name" {
  description = "Name of the TLS secret created by the Certificate"
  value       = "${var.name}-certificate-tls"
}
