# Namespaces are created by the stack (e.g. via components/k8s/namespace).
# controller_namespace and runner_namespace are passed in by the caller.

# Default resource limits for containers in the runner namespace (LimitRange).
# When enable_dind is true we do not pass a custom pod template, so runner pod containers
# (init-dind-externals, dind, runner) get these defaults. When enable_dind is false we also
# pass these via the runner template; the LimitRange still applies to any other pods in the namespace.
# Memory request is set equal to limit (guaranteed for memory); CPU request defaults to the
# CPU limit unless runner_cpu_request is set, allowing burstable QoS for CPU.
# CPU/memory are formatted to match Kubernetes' normalized form (e.g. "2" not "2000m", "4Gi" not "4096Mi")
# to avoid perpetual plan drift.
locals {
  _cpu_request_raw = var.runner_cpu_request != null ? var.runner_cpu_request : var.runner_cpu_limit
  _cpu_limit_qty   = var.runner_cpu_limit != null && var.runner_cpu_limit % 1000 == 0 ? tostring(var.runner_cpu_limit / 1000) : var.runner_cpu_limit != null ? "${var.runner_cpu_limit}m" : null
  _cpu_request_qty = local._cpu_request_raw != null && local._cpu_request_raw % 1000 == 0 ? tostring(local._cpu_request_raw / 1000) : local._cpu_request_raw != null ? "${local._cpu_request_raw}m" : null
  _mem_limit_qty   = var.runner_memory_limit != null && var.runner_memory_limit % 1024 == 0 ? "${var.runner_memory_limit / 1024}Gi" : var.runner_memory_limit != null ? "${var.runner_memory_limit}Mi" : null
  _mem_request_qty = local._mem_limit_qty
}

resource "kubernetes_limit_range_v1" "runner_namespace_defaults" {
  count = (var.runner_cpu_limit != null || var.runner_memory_limit != null) ? 1 : 0

  metadata {
    name      = "default-resources"
    namespace = var.runner_namespace
  }
  spec {
    limit {
      type = "Container"
      default = merge(
        local._cpu_limit_qty != null ? { cpu = local._cpu_limit_qty } : {},
        local._mem_limit_qty != null ? { memory = local._mem_limit_qty } : {},
      )
      default_request = merge(
        local._cpu_request_qty != null ? { cpu = local._cpu_request_qty } : {},
        local._mem_request_qty != null ? { memory = local._mem_request_qty } : {},
      )
    }
  }
}

# GitHub credentials secret for the runner scale set (PAT)

resource "kubernetes_secret_v1" "github_config" {
  metadata {
    name      = "github-config-secret"
    namespace = var.runner_namespace
  }
  data = {
    github_token = var.github_token
  }
}

# ARC controller (must be installed before runner scale set)

resource "helm_release" "controller" {
  name       = "arc"
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set-controller"
  version    = var.controller_chart_version
  namespace  = var.controller_namespace

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 300
}

# Runner scale set (listener + ephemeral runner pods)

locals {
  runner_resources = var.runner_cpu_limit != null || var.runner_memory_limit != null ? {
    limits = merge(
      var.runner_cpu_limit != null ? { cpu = "${var.runner_cpu_limit}m" } : {},
      var.runner_memory_limit != null ? { memory = "${var.runner_memory_limit}Mi" } : {},
    )
    requests = merge(
      var.runner_cpu_limit != null ? { cpu = "${local._cpu_request_raw}m" } : {},
      var.runner_memory_limit != null ? { memory = "${var.runner_memory_limit}Mi" } : {},
    )
  } : {}

  tolerations_spec = var.tolerate_peak_workloads ? {
    tolerations = [
      {
        key      = "node.kubernetes.io/role"
        operator = "Equal"
        value    = "peak-workloads"
        effect   = "NoExecute"
      }
    ]
  } : {}

  # Annotation hints the descheduler to skip these pods during LowNodeUtilization /
  # TopologySpread rebalancing — runner pods are job-bound and eviction cancels the CI job.
  pod_metadata = {
    annotations = {
      "descheduler.alpha.kubernetes.io/prefer-no-eviction" = "true"
    }
  }

  # When enable_dind is true, the chart owns the pod template (dind sidecar etc.); we
  # pass a metadata-only template patch (plus tolerations when set), which the chart
  # deep-merges with its generated spec.
  # When enable_dind is false, we pass a full template so we can mount /opt/hostedtoolcache
  # (required by setup-ruby and other setup-* actions). Resource limits are merged in when set.
  # Each branch is yamlencoded independently so the ternary unifies on string, not on object shape.
  helm_values_yaml = var.enable_dind ? yamlencode(merge(
    { containerMode = { type = "dind" } },
    {
      template = merge(
        { metadata = local.pod_metadata },
        var.tolerate_peak_workloads ? { spec = local.tolerations_spec } : {},
      )
    },
    )) : yamlencode({
    template = {
      metadata = local.pod_metadata
      spec = merge(
        {
          containers = [
            {
              name      = "runner"
              image     = var.runner_image
              command   = ["/home/runner/run.sh"]
              resources = local.runner_resources
              volumeMounts = [
                {
                  name      = "hostedtoolcache"
                  mountPath = "/opt/hostedtoolcache"
                }
              ]
            }
          ]
          volumes = [
            {
              name     = "hostedtoolcache"
              emptyDir = {}
            }
          ]
        },
        local.tolerations_spec,
      )
    }
  })
}

resource "helm_release" "runner_scale_set" {
  name       = var.installation_name
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set"
  version    = var.runner_chart_version
  namespace  = var.runner_namespace

  atomic        = true
  wait          = true
  wait_for_jobs = true
  timeout       = 300

  set = [
    {
      name  = "githubConfigUrl"
      value = var.github_config_url
    },
    {
      name  = "githubConfigSecret"
      value = kubernetes_secret_v1.github_config.metadata[0].name
    },
    {
      name  = "minRunners"
      value = tostring(var.min_runners)
    },
    {
      name  = "maxRunners"
      value = tostring(var.max_runners)
    },
  ]

  values = [local.helm_values_yaml]

  depends_on = [helm_release.controller]
}
