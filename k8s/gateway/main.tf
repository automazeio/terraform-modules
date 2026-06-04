resource "kubernetes_manifest" "certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "${var.name}-certificate"
      namespace = var.namespace
      labels    = var.labels
    }
    spec = {
      secretName = "${var.name}-certificate-tls"
      issuerRef = {
        name = var.letsencrypt_name
        kind = "ClusterIssuer"
      }
      dnsNames = var.hosts
    }
  }
}

resource "kubernetes_manifest" "ingress_route_tcp" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRouteTCP"
    metadata = {
      name      = "${var.name}-ingress-tcp"
      namespace = var.namespace
      labels    = var.labels
    }
    spec = {
      entryPoints = [var.entrypoint]
      routes = [
        {
          match = join(" || ", [for host in var.hosts : "HostSNI(`${host}`)"])
          services = [
            {
              name = var.service_name
              port = var.service_port
            }
          ]
        }
      ]
      tls = {
        secretName  = "${var.name}-certificate-tls"
        passthrough = false
      }
    }
  }

  depends_on = [kubernetes_manifest.certificate]
}
