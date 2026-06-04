resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.20.1"
  namespace        = "cert-manager"
  create_namespace = true

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 120

  set = [
    {
      name  = "crds.enabled"
      value = "true"
    },
  ]
}
