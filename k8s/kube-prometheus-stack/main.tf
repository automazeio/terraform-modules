resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version
  namespace  = var.namespace_name

  create_namespace = var.create_namespace

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 120

  values = [
    yamlencode({
      grafana = {
        enabled = false
      }

      prometheus = {
        prometheusSpec = merge(
          {
            # Accept remote_write from Alloy agents in prod regions (EU/US/AU)
            enableRemoteWriteReceiver = true
            retention                 = var.retention

            # Sized from live usage (~1.5Gi / 150m). Generous memory limit absorbs
            # WAL-replay/query spikes and growth in active series from remote_write.
            # No CPU limit on purpose: CPU throttling here causes scrape/query timeouts.
            resources = {
              requests = {
                cpu    = "250m"
                memory = "1536Mi"
              }
              limits = {
                memory = "3Gi"
              }
            }
          },
          var.retention_size == null ? {} : {
            retentionSize = var.retention_size
          },
          var.storage_size == null ? {} : {
            storageSpec = {
              volumeClaimTemplate = {
                spec = merge(
                  {
                    accessModes = ["ReadWriteOnce"]
                    resources = {
                      requests = {
                        storage = var.storage_size
                      }
                    }
                  },
                  var.storage_class_name == null ? {} : {
                    storageClassName = var.storage_class_name
                  },
                )
              }
            }
          },
        )
      }

      alertmanager = {
        alertmanagerSpec = {
          resources = {
            requests = {
              cpu    = "25m"
              memory = "128Mi"
            }
            limits = {
              memory = "256Mi"
            }
          }
        }
      }

      prometheusOperator = {
        resources = {
          requests = {
            cpu    = "25m"
            memory = "128Mi"
          }
          limits = {
            memory = "256Mi"
          }
        }

        # Tiny config-reloader sidecars injected into Prometheus/Alertmanager pods.
        prometheusConfigReloader = {
          resources = {
            requests = {
              cpu    = "10m"
              memory = "32Mi"
            }
            limits = {
              memory = "64Mi"
            }
          }
        }
      }

      # Subchart key (hyphens) – image is defined in the kube-state-metrics subchart
      "kube-state-metrics" = {
        image = {
          registry   = "docker.io"
          repository = "rancher/mirrored-kube-state-metrics-kube-state-metrics"
          tag        = "v2.17.0"
        }

        resources = {
          requests = {
            cpu    = "25m"
            memory = "128Mi"
          }
          limits = {
            memory = "192Mi"
          }
        }
      }

      # node-exporter disabled: no dashboards query node_* metrics today, and the
      # bundled DaemonSet was log-spamming with /host/proc/1/mountinfo permission
      # errors on k3s. Re-enable (with containerSecurityContext.runAsUser = 0) if
      # you ever add a node-level dashboard.
      nodeExporter = {
        enabled = false
      }
      "prometheus-node-exporter" = {
        enabled = false
      }
    })
  ]
}
