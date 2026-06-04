# SSH Keys Component Outputs

output "master_ssh" {
  description = "Master node SSH key pair"
  value = {
    public_key  = tls_private_key.master_ssh.public_key_openssh
    private_key = tls_private_key.master_ssh.private_key_openssh
  }
  sensitive = true
}

output "worker_ssh" {
  description = "Worker nodes SSH key pair"
  value = {
    public_key  = tls_private_key.worker_ssh.public_key_openssh
    private_key = tls_private_key.worker_ssh.private_key_openssh
  }
  sensitive = true
}
