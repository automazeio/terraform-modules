resource "kubernetes_job_v1" "ecr_initial_token" {
  metadata {
    name      = "ecr-initial-token"
    namespace = var.namespace_name
  }

  spec {
    template {
      metadata {
        labels = {
          app = "ecr-initial-token"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.ecr_service_account.metadata[0].name
        restart_policy       = "OnFailure"

        container {
          name    = local.ecr_container_config.name
          image   = local.ecr_container_config.image
          command = local.ecr_container_config.command

          dynamic "env_from" {
            for_each = local.ecr_container_config.env_from
            content {
              secret_ref {
                name = env_from.value.secret_ref.name
              }
            }
          }

          resources {
            limits   = local.ecr_container_config.resources.limits
            requests = local.ecr_container_config.resources.requests
          }
        }
      }
    }

    # ttl_seconds_after_finished = 3600
  }

  wait_for_completion = true
  timeouts {
    create = "5m"
    update = "5m"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_cron_job_v1" "ecr_token_refresh" {
  metadata {
    name      = "ecr-token-refresh"
    namespace = var.namespace_name
  }

  spec {
    schedule                      = "0 */6 * * *" # Every 6 hours
    successful_jobs_history_limit = 3
    failed_jobs_history_limit     = 1

    job_template {
      metadata {
        labels = {
          app = "ecr-token-refresh"
        }
      }

      spec {
        template {
          metadata {
            labels = {
              app = "ecr-token-refresh"
            }
          }

          spec {
            service_account_name = kubernetes_service_account_v1.ecr_service_account.metadata[0].name
            restart_policy       = "OnFailure"

            container {
              name    = local.ecr_container_config.name
              image   = local.ecr_container_config.image
              command = local.ecr_container_config.command

              dynamic "env_from" {
                for_each = local.ecr_container_config.env_from
                content {
                  secret_ref {
                    name = env_from.value.secret_ref.name
                  }
                }
              }

              resources {
                limits   = local.ecr_container_config.resources.limits
                requests = local.ecr_container_config.resources.requests
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_job_v1.ecr_initial_token
  ]
}
