# Grafana Loki (single binary, filesystem storage) — config from
# https://sagar-srivastava.medium.com/setting-up-grafana-loki-on-kubernetes-a-simplified-guide-97fbf850ba55
# Using Longhorn for persistence; gateway/caches disabled to avoid extra PVCs.

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = var.chart_version
  namespace  = var.namespace_name

  create_namespace = false

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 200

  values = [
    yamlencode({
      deploymentMode = "SingleBinary"

      loki = {
        auth_enabled = false
        commonConfig = {
          replication_factor = 1
          path_prefix        = "/var/loki"
        }
        # Helm chart requires bucketNames when object_store is set; for filesystem these act as path names
        storage = {
          type = "filesystem"
          bucketNames = {
            chunks = "chunks"
            ruler  = "ruler"
            admin  = "admin"
          }
          filesystem = {
            chunks_directory = "/var/loki/chunks"
            rules_directory  = "/var/loki/rules"
          }
        }
        schemaConfig = {
          configs = [
            {
              from         = "2024-04-01"
              store        = "tsdb"
              object_store = "filesystem"
              schema       = "v13"
              index = {
                prefix = "loki_index_"
                period = "24h"
              }
            }
          ]
        }
        pattern_ingester = {
          enabled = true
        }
        limits_config = {
          allow_structured_metadata = true
          volume_enabled            = true
          retention_period          = "720h"
        }
        compactor = {
          retention_enabled    = true
          delete_request_store = "filesystem"
        }
        ruler = {
          enable_api = true
        }
      }

      minio = {
        enabled = false
      }

      lokiCanary = {
        enabled = false
      }

      test = {
        enabled = false
      }

      gateway = {
        enabled = true
        # nginx proxy is tiny (~15Mi). Memory-capped only; no CPU limit (avoids throttling).
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

      chunksCache = {
        enabled = false
      }

      singleBinary = {
        replicas = 1
        # Wires in local.resources_values (previously computed but never applied,
        # which is why loki-0 ran with no requests/limits).
        resources = local.resources_values
        persistence = {
          enabled      = true
          size         = var.persistence_size
          storageClass = var.persistence_storage_class
          mountPath    = "/var/loki"
        }
      }

      # Allow memberlist DNS to resolve during startup (single-binary pod must resolve
      # loki-memberlist before it becomes ready; see grafana/loki#7907).
      memberlist = {
        service = {
          publishNotReadyAddresses = true
        }
      }

      # Zero out replica counts of other deployment modes
      backend        = { replicas = 0 }
      read           = { replicas = 0 }
      write          = { replicas = 0 }
      ingester       = { replicas = 0 }
      querier        = { replicas = 0 }
      queryFrontend  = { replicas = 0 }
      queryScheduler = { replicas = 0 }
      distributor    = { replicas = 0 }
      compactor      = { replicas = 0 }
      indexGateway   = { replicas = 0 }
      bloomCompactor = { replicas = 0 }
      bloomGateway   = { replicas = 0 }
    })
  ]
}
