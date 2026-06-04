resource "helm_release" "descheduler" {
  name       = "descheduler"
  repository = "https://kubernetes-sigs.github.io/descheduler/"
  chart      = "descheduler"
  version    = var.chart_version
  namespace  = var.namespace_name

  create_namespace = var.create_namespace

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 120

  values = [
    yamlencode({
      kind     = "CronJob"
      schedule = var.schedule
      deschedulerPolicy = {
        # Cap evictions per node per run. With the spread plugin listed first,
        # a scarce eviction budget goes to spread before node-usage balancing.
        maxNoOfPodsToEvictPerNode = var.max_no_of_pods_to_evict_per_node
        metricsProviders = [
          {
            source = "KubernetesMetrics"
          },
        ]
        profiles = [
          {
            name = "default"
            pluginConfig = [
              {
                name = "DefaultEvictor"
                args = {
                  nodeFit = true
                }
              },
              {
                name = "LowNodeUtilization"
                args = {
                  thresholds       = var.low_node_utilization_thresholds
                  targetThresholds = var.low_node_utilization_target_thresholds
                  metricsUtilization = {
                    source = "KubernetesMetrics"
                  }
                }
              },
              {
                name = "RemovePodsViolatingTopologySpreadConstraint"
                args = {
                  # Default is [DoNotSchedule] only. Adding ScheduleAnyway lets
                  # the descheduler also rebalance our soft spread constraints;
                  # keeping DoNotSchedule preserves the out-of-the-box behavior.
                  constraints = ["DoNotSchedule", "ScheduleAnyway"]
                }
              },
            ]
            plugins = {
              balance = {
                # Order = priority when an eviction cap is set: spread first, so
                # rebalancing-for-spread isn't starved by node-usage balancing.
                enabled = [
                  "RemovePodsViolatingTopologySpreadConstraint",
                  "LowNodeUtilization",
                ]
              }
            }
          },
        ]
      }
    })
  ]
}
