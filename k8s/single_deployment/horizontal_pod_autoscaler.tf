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
          average_utilization = var.horizontal_pod_autoscaler_cpu_utilization_percentage
        }
      }
    }

    # Memory metric. Keep its target ABOVE the CPU target so CPU stays the primary
    # scaler, and size memory_request_ratio so normal usage sits under this target --
    # otherwise, since per-pod memory doesn't fall when replicas are added, the HPA
    # ratchets to max_replicas and never scales back down.
    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = var.horizontal_pod_autoscaler_memory_utilization_percentage
        }
      }
    }

    # Only render a behavior block when a scale-up stabilization window is set.
    # Without it Kubernetes applies its default scaleUp window of 0s, which adds
    # a replica on any momentary CPU spike and drives 2<->3 flapping; each
    # scale-down then risks dropping in-flight connections (502s). A non-zero
    # window makes the controller require the load to persist before scaling up.
    dynamic "behavior" {
      for_each = var.horizontal_pod_autoscaler.scale_up_stabilization_seconds != null ? [1] : []
      content {
        scale_up {
          stabilization_window_seconds = var.horizontal_pod_autoscaler.scale_up_stabilization_seconds
          select_policy                = "Max"
          policy {
            period_seconds = 15
            type           = "Pods"
            value          = 4
          }
          policy {
            period_seconds = 15
            type           = "Percent"
            value          = 100
          }
        }
        scale_down {
          stabilization_window_seconds = var.horizontal_pod_autoscaler.scale_down_stabilization_seconds
          select_policy                = "Max"
          policy {
            period_seconds = 15
            type           = "Percent"
            value          = 100
          }
        }
      }
    }
  }
}
