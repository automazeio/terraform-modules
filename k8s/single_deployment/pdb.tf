# Keeps at least one pod available during voluntary disruptions (node drains,
# DOKS upgrades, descheduler evictions). Only created for multi-replica
# deployments: a PDB with min_available = 1 on a single-replica deployment would
# block node drains entirely (0 disruptions allowed -> drain hangs).
resource "kubernetes_pod_disruption_budget_v1" "pdb" {
  count = var.horizontal_pod_autoscaler.min_replicas > 1 ? 1 : 0

  metadata {
    name      = "${var.name}-pdb"
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    min_available = 1
    selector {
      match_labels = local.labels
    }
  }
}
