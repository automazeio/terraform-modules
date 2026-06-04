resource "helm_release" "alloy" {
  name       = "alloy"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  version    = "0.11.0"
  namespace  = var.namespace_name

  create_namespace = false

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 120

  values = [
    yamlencode({
      controller = {
        type     = "deployment"
        replicas = 1
      }
      alloy = {
        resources = var.resources
        configMap = {
          create  = true
          content = <<-EOT
            logging {
              level = "info"
              format = "logfmt"
            }
            discovery.kubernetes "pods" {
              role = "pod"

              namespaces {
                names = ${jsonencode(var.watch_namespaces)}
              }
            }
            discovery.relabel "pods" {
              targets = discovery.kubernetes.pods.targets

              rule {
                source_labels = ["__meta_kubernetes_pod_controller_kind"]
                regex         = "ReplicaSet"
                action        = "keep"
              }

              rule {
                source_labels = ["__meta_kubernetes_namespace"]
                target_label  = "namespace"
                action        = "replace"
              }

              rule {
                source_labels = ["namespace"]
                regex         = "app"
                target_label  = "namespace"
                replacement   = "production"
                action        = "replace"
              }

              rule {
                source_labels = ["__meta_kubernetes_pod_container_name"]
                target_label  = "container"
                action        = "replace"
              }
            }
            loki.source.kubernetes "pods" {
              targets    = discovery.relabel.pods.output
              forward_to = [loki.process.process.receiver]
            }
            loki.process "process" {
              forward_to = [loki.write.loki.receiver]

              stage.drop {
                older_than          = "1h"
                drop_counter_reason = "too old"
              }
            }
            loki.write "loki" {
              endpoint {
                url = "${var.loki_remote_write_url}"
%{if var.loki_remote_write_username != null~}
                basic_auth {
                  username = "${var.loki_remote_write_username}"
                  password = "${var.loki_remote_write_password}"
                }
%{endif~}
              }
%{if var.location_label != null~}
              external_labels = {
                location = "${var.location_label}",
              }
%{endif~}
            }

            // ── Metrics collection ──────────────────────────────

            discovery.kubernetes "nodes" {
              role = "node"
            }

            discovery.kubernetes "kube_state_metrics" {
              role = "pod"

              namespaces {
                names = ["monitoring"]
              }

              selectors {
                role  = "pod"
                label = "app.kubernetes.io/name=kube-state-metrics"
              }
            }

            discovery.relabel "kube_state_metrics" {
              targets = discovery.kubernetes.kube_state_metrics.targets

              rule {
                source_labels = ["__meta_kubernetes_pod_container_port_number"]
                regex         = "8080"
                action        = "keep"
              }
            }

            discovery.relabel "cadvisor" {
              targets = discovery.kubernetes.nodes.targets

              rule {
                replacement  = "/metrics/cadvisor"
                target_label = "__metrics_path__"
              }

              rule {
                source_labels = ["__meta_kubernetes_node_name"]
                target_label  = "node"
              }
            }

            // Keep only the cadvisor metrics used by dashboards, and drop
            // high-cardinality labels (id, name) that are never queried.
            prometheus.relabel "cadvisor_filter" {
              forward_to = [prometheus.remote_write.central.receiver]

              rule {
                source_labels = ["__name__"]
                regex         = "container_cpu_usage_seconds_total|container_memory_working_set_bytes|container_oom_events_total"
                action        = "keep"
              }

              rule {
                regex  = "id|name"
                action = "labeldrop"
              }
            }

            // Keep only the kube-state-metrics families used by dashboards.
            prometheus.relabel "ksm_filter" {
              forward_to = [prometheus.remote_write.central.receiver]

              rule {
                source_labels = ["__name__"]
                regex         = "kube_pod_status_phase|kube_pod_container_status_restarts_total|kube_pod_container_resource_limits"
                action        = "keep"
              }
            }

            prometheus.scrape "cadvisor" {
              targets         = discovery.relabel.cadvisor.output
              scheme          = "https"
              scrape_interval = "30s"
              bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"
              tls_config {
                insecure_skip_verify = true
              }
              forward_to = [prometheus.relabel.cadvisor_filter.receiver]
            }

            prometheus.scrape "kube_state_metrics" {
              targets         = discovery.relabel.kube_state_metrics.output
              scrape_interval = "30s"
              forward_to      = [prometheus.relabel.ksm_filter.receiver]
            }

            prometheus.remote_write "central" {
              endpoint {
                url = "${var.metrics_remote_write_url}"
%{if var.metrics_remote_write_username != null~}
                basic_auth {
                  username = "${var.metrics_remote_write_username}"
                  password = "${var.metrics_remote_write_password}"
                }
%{endif~}
              }
%{if var.location_label != null~}
              external_labels = {
                location = "${var.location_label}",
              }
%{endif~}
            }
          EOT
        }
      }
    })
  ]
}
