resource "kubernetes_deployment_v1" "deployment" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  spec {
    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        labels = local.labels
        annotations = {
          "configmap-name" = kubernetes_config_map_v1.config_map.metadata[0].name
          "configmap-hash" = sha256(jsonencode(kubernetes_config_map_v1.config_map.data))
          "secret-name"    = kubernetes_secret_v1.secret.metadata[0].name
          "secret-hash"    = sha256(jsonencode(kubernetes_secret_v1.secret.data))
        }
      }

      spec {
        container {
          image             = var.container_image
          name              = var.name
          image_pull_policy = "Always"

          port {
            container_port = var.container_port
            name           = "http"
          }

          dynamic "resources" {
            for_each = var.max_resources != null ? [1] : []
            content {
              limits = {
                cpu    = "${var.max_resources.cpu}m"
                memory = "${var.max_resources.memory}Mi"
              }
              requests = {
                cpu    = "${floor(var.max_resources.cpu * 0.5)}m"
                memory = "${floor(var.max_resources.memory * 0.5)}Mi"
              }
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.config_map.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.secret.metadata[0].name
            }
          }

          dynamic "startup_probe" {
            for_each = var.health_check_path != null && var.startup_probe != null ? [1] : []
            content {
              http_get {
                path = var.health_check_path
                port = var.container_port
              }
              initial_delay_seconds = var.startup_probe.initial_delay_seconds
              period_seconds        = var.startup_probe.period_seconds
              failure_threshold     = var.startup_probe.failure_threshold
            }
          }

          dynamic "readiness_probe" {
            for_each = var.readiness_probe != null ? [1] : []
            content {
              http_get {
                path = var.readiness_probe.path
                port = var.container_port
              }
              period_seconds    = var.readiness_probe.period_seconds
              timeout_seconds   = var.readiness_probe.timeout_seconds
              failure_threshold = var.readiness_probe.failure_threshold
            }
          }

          dynamic "liveness_probe" {
            for_each = var.liveness_probe != null ? [1] : []
            content {
              http_get {
                path = var.liveness_probe.path
                port = var.container_port
              }
              initial_delay_seconds = var.liveness_probe.initial_delay_seconds
              period_seconds        = var.liveness_probe.period_seconds
              timeout_seconds       = var.liveness_probe.timeout_seconds
              failure_threshold     = var.liveness_probe.failure_threshold
            }
          }

          dynamic "volume_mount" {
            for_each = var.extra_volume_mounts
            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.mount_path
              sub_path   = volume_mount.value.sub_path
              read_only  = volume_mount.value.read_only
            }
          }
        }

        dynamic "volume" {
          for_each = var.extra_volumes
          content {
            name = volume.value.name
            config_map {
              name = volume.value.config_map_name
            }
          }
        }

        # Best-effort spread of replicas across nodes. ScheduleAnyway (soft) so a
        # pod is never left Pending when no extra node is free: it schedules
        # (possibly co-located) and the descheduler rebalances later once
        # capacity frees up. Only meaningful for multi-replica deployments.
        dynamic "topology_spread_constraint" {
          for_each = var.horizontal_pod_autoscaler.min_replicas > 1 ? [1] : []
          content {
            max_skew           = 1
            topology_key       = "kubernetes.io/hostname"
            when_unsatisfiable = "ScheduleAnyway"
            label_selector {
              match_labels = local.labels
            }
          }
        }

        # Soft pull toward worker (non-control-plane) nodes. Preferred, not
        # required, so pods still schedule on control-plane nodes when workers
        # are full — never Pending. No-op where nodes have no control-plane
        # label (e.g. managed DOKS / AU).
        dynamic "affinity" {
          for_each = var.prefer_non_control_plane ? [1] : []
          content {
            node_affinity {
              preferred_during_scheduling_ignored_during_execution {
                weight = 100
                preference {
                  match_expressions {
                    key      = "node-role.kubernetes.io/control-plane"
                    operator = "DoesNotExist"
                  }
                }
              }
            }
          }
        }

        service_account_name = var.service_account_name
      }
    }
  }


  lifecycle {
    ignore_changes = [
      spec[0].template[0].spec[0].container[0].image
    ]
  }
}
