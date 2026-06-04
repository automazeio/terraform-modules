output "name" {
  description = "Name of the Let's Encrypt cluster issuer"
  value       = kubernetes_manifest.letsencrypt_issuer.manifest.metadata.name
}
