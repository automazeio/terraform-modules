# SSH Keys Component
# Generates and manages SSH keys for the Kubernetes clusters

# Generate SSH keys dynamically
resource "tls_private_key" "master_ssh" {
  algorithm = "ED25519"
}

resource "tls_private_key" "worker_ssh" {
  algorithm = "ED25519"
}
