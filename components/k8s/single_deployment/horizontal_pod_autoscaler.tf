resource "kubernetes_horizontal_pod_autoscaler_v2" "horizontal_pod_autoscaler" {
  metadata {
    name      = "${var.name}-hpa"
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.deployment.metadata[0].name
    }

    min_replicas = var.horizontal_pod_autoscaler.min_replicas
    max_replicas = var.horizontal_pod_autoscaler.max_replicas

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.horizontal_pod_autoscaler.cpu_utilization_percentage
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = var.horizontal_pod_autoscaler.memory_utilization_percentage
        }
      }
    }
  }
}
