locals {
  kured_day_codes = {
    monday    = "mo"
    tuesday   = "tu"
    wednesday = "we"
    thursday  = "th"
    friday    = "fr"
    saturday  = "sa"
    sunday    = "su"
  }
  kured_reboot_day = var.maintenance_policy.day == "any" ? join(",", values(local.kured_day_codes)) : local.kured_day_codes[var.maintenance_policy.day]

  kured_end_time = formatdate("HH:mm", timeadd("2000-01-01T${var.maintenance_policy.start_time}:00Z", "4h"))

  hetzner_location_time_zone = {
    fsn1 = "Europe/Berlin"
    nbg1 = "Europe/Berlin"
    hel1 = "Europe/Helsinki"
    ash  = "America/New_York"
    hil  = "America/Los_Angeles"
    sin  = "Asia/Singapore"
  }
  kured_time_zone = local.hetzner_location_time_zone[var.region_config.location]
}

module "kube-hetzner" {
  providers = {
    hcloud = hcloud
  }

  traefik_version = "39.0.7"
  # No --log.level=DEBUG: prod runs at the chart default (INFO). The DEBUG flag
  # here leaked verbose logs and surfaced as a duplicate --log.level arg.
  traefik_additional_options = []

  # Pin the system log to INFO (the --log.level=DEBUG above is dropped). Access
  # log left OFF on purpose: Alloy doesn't ship the `traefik` namespace to Loki,
  # so access lines would only reach pod stdout and never be queryable.
  traefik_merge_values = <<-EOT
logs:
  general:
    level: INFO
ports:
  mongodb:
    port: 27017
    expose:
      default: true
    exposedPort: 27017
    protocol: TCP
    proxyProtocol:
      trustedIPs:
        - 127.0.0.1/32
        - 10.0.0.0/8
    transport:
      respondingTimeouts:
        readTimeout: 30m
  EOT

  cert_manager_version = "1.20.1"

  kured_version = "1.21.0"

  hcloud_token = var.hcloud_token

  source  = "kube-hetzner/kube-hetzner/hcloud"
  version = "2.19.2"

  ssh_port        = 2220
  ssh_public_key  = var.ssh_keys.master_ssh.public_key
  ssh_private_key = var.ssh_keys.master_ssh.private_key

  network_region = var.region_config.network_zone

  cluster_name = "${var.region_config.name}-k3s"

  allow_scheduling_on_control_plane = true

  control_plane_nodepools = [
    {
      name        = "control-plane",
      server_type = var.server_type.master,
      location    = var.region_config.location,
      labels      = [],
      taints      = [],
      count       = var.high_availability ? 3 : 1,
      swap_size   = "8G",
    }
  ]

  agent_nodepools = [
    {
      name        = "agent-1",
      server_type = var.server_type.worker,
      location    = var.region_config.location,
      labels      = [],
      taints      = [],
      count       = var.high_availability ? var.worker_count : 0,
      swap_size   = "8G",
    },
  ]

  autoscaler_nodepools = [
    for pair in setproduct(var.autoscaler.locations, var.autoscaler.types) : {
      name        = "autoscaled-${pair[1]}-${pair[0]}"
      server_type = pair[1]
      location    = pair[0]
      min_nodes   = 0
      max_nodes   = var.autoscaler.max_nodes
      swap_size   = "8G"
      labels = {
        "node.kubernetes.io/role" : "peak-workloads"
      }
      taints = [
        {
          key    = "node.kubernetes.io/role"
          value  = "peak-workloads"
          effect = "NoExecute"
        }
      ]
    }
  ]

  cluster_autoscaler_extra_args = [
    "--ignore-daemonsets-utilization=true",
    "--max-nodes-total=${(var.high_availability ? 3 : 1) + (var.high_availability ? var.worker_count : 0) + var.autoscaler.max_nodes}",
    "--expander=least-waste",
  ]

  ingress_replica_count = var.high_availability ? (3 + var.worker_count) : 1

  load_balancer_type     = "lb11"
  load_balancer_location = var.region_config.location

  additional_tls_sans       = var.control_plane_hostname == null ? [] : [var.control_plane_hostname]
  kubeconfig_server_address = var.control_plane_hostname == null ? "" : var.control_plane_hostname

  dns_servers = [
    # "1.1.1.1",
    "8.8.8.8",
    "2606:4700:4700::1111",
  ]

  microos_x86_snapshot_id = var.microos_x86_snapshot_id
  microos_arm_snapshot_id = var.microos_arm_snapshot_id

  create_kubeconfig    = false
  create_kustomization = false

  extra_firewall_rules = [
    {
      description     = "Allow all outbound traffic"
      direction       = "out"
      protocol        = "tcp"
      port            = "1-65535"
      source_ips      = [] # Won't be used for outbound rules
      destination_ips = ["0.0.0.0/0", "::/0"]
    },
    {
      description     = "Allow all outbound UDP traffic"
      direction       = "out"
      protocol        = "udp"
      port            = "1-65535"
      source_ips      = [] # Won't be used for outbound rules
      destination_ips = ["0.0.0.0/0", "::/0"]
    },
    {
      description     = "Allow all outbound ICMP traffic"
      direction       = "out"
      protocol        = "icmp"
      port            = ""
      source_ips      = [] # Won't be used for outbound rules
      destination_ips = ["0.0.0.0/0", "::/0"]
    }
  ]

  enable_longhorn        = var.enable_longhorn
  longhorn_replica_count = var.longhorn_replica_count

  longhorn_values = <<EOT
defaultSettings:
  createDefaultDiskLabeledNodes: false
  defaultDataPath: /var/longhorn
  defaultReplicaCount: ${var.longhorn_replica_count}
  node-down-pod-deletion-policy: delete-both-statefulset-and-deployment-pod
  node-drain-policy: allow-if-replica-is-stopped
persistence:
  defaultFsType: ext4
  defaultClassReplicaCount: ${var.longhorn_replica_count}
  defaultClass: true
  reclaimPolicy: Retain
  EOT

  automatically_upgrade_k3s = false
  automatically_upgrade_os  = var.high_availability
  install_k3s_version       = "v1.35.3+k3s1"

  kured_options = {
    "reboot-days"   = local.kured_reboot_day
    "start-time"    = var.maintenance_policy.start_time
    "end-time"      = local.kured_end_time
    "time-zone"     = local.kured_time_zone
    "drain-timeout" = "15m"
  }
}
