# Terraform / OpenTofu Kubernetes Modules

A collection of reusable Terraform / [OpenTofu](https://opentofu.org/) modules for
provisioning and operating multi-cloud Kubernetes infrastructure: clusters on
**Hetzner Cloud (k3s)** and **DigitalOcean**, DNS on **Cloudflare**, and a catalog of
in-cluster building blocks (ingress, certificates, observability, registries,
databases, and a generic application deployment).

These modules are provider-agnostic where possible and designed to be composed —
several of them call each other (e.g. most ingress-capable modules reuse
`k8s/single_deployment/ingress`).

## Requirements

- [OpenTofu](https://opentofu.org/) ≥ 1.6 (or Terraform ≥ 1.6)
- Provider credentials for whatever you use: Hetzner Cloud, DigitalOcean,
  Cloudflare, AWS (ECR), Kubernetes, Helm.
- Some modules wrap upstream Helm charts or modules and require the cluster to
  already exist (Kubernetes/Helm providers configured by the caller).

## Usage

Reference a module by its path within this repository. Pin to a tag so upgrades
are deliberate:

```hcl
module "namespace" {
  source = "github.com/automazeio/terraform-modules//k8s/namespace?ref=v1.0.0"

  name = "app"
}

module "app" {
  source = "github.com/automazeio/terraform-modules//k8s/single_deployment?ref=v1.0.0"

  name      = "api"
  namespace = module.namespace.name
  image     = "ghcr.io/your-org/api:latest"
  # ... see k8s/single_deployment/variables.tf for the full input list
}
```

> **Note:** every module's inputs and outputs are declared in its own
> `variables.tf` / `outputs.tf`. Secrets are always passed in as `sensitive`
> variables — nothing is baked into the modules.

## Module catalog

### Infrastructure / cloud

| Module | Purpose |
|--------|---------|
| `hetzner` | Hetzner Cloud k3s cluster (wraps [`kube-hetzner`](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner)); includes a Packer template for openSUSE MicroOS snapshots |
| `digital_ocean/k8s_cluster` | DigitalOcean managed Kubernetes cluster |
| `cloudflare` | Cloudflare DNS records for a managed zone |
| `ssh-keys` | TLS keypairs (e.g. master/worker SSH keys for Hetzner) |
| `github` | GitHub Actions integration — manage secrets and generate a build/push/deploy workflow |

### Kubernetes — platform

| Module | Purpose |
|--------|---------|
| `k8s/namespace` | Namespace |
| `k8s/cert_manager` | cert-manager installation |
| `k8s/letsencrypt` | Let's Encrypt `ClusterIssuer` (DNS-01 challenge) |
| `k8s/traefik` | Traefik ingress controller |
| `k8s/gateway` | Traefik `IngressRouteTCP` + cert-manager `Certificate` for non-HTTP (TCP) services |
| `k8s/metrics-server` | Kubernetes Metrics Server |
| `k8s/descheduler` | Descheduler for rebalancing pods |
| `k8s/ecr` | AWS ECR pull credentials + a CronJob that refreshes the registry token |
| `k8s/harbor` | Self-hosted Harbor registry — `init`, `setup`, and `service_account` submodules |

### Kubernetes — observability

| Module | Purpose |
|--------|---------|
| `k8s/kube-prometheus-stack` | Prometheus + Alertmanager + Grafana stack |
| `k8s/kube-state-metrics` | Standalone kube-state-metrics |
| `k8s/grafana/dashboard` | Grafana instance |
| `k8s/grafana/loki` | Loki log aggregation |
| `k8s/grafana/alloy` | Grafana Alloy agent (logs + metrics collection, remote-write) |

### Kubernetes — data

| Module | Purpose |
|--------|---------|
| `k8s/postgresql` | PostgreSQL (Helm) |
| `k8s/mongodb` | MongoDB (Helm), optionally exposed over TCP via `gateway` |
| `k8s/redis` | Redis |
| `k8s/databasus` | [Databasus](https://github.com/databasus/databasus) database backup tool (PostgreSQL/MySQL/MongoDB) |

### Kubernetes — applications

| Module | Purpose |
|--------|---------|
| `k8s/single_deployment` | Generic application: Deployment + Service + Ingress + HPA + PDB + ConfigMap/Secret |
| `k8s/single_deployment/ingress` | Standalone ingress submodule (reused by other modules) |
| `k8s/arc_runner` | GitHub Actions Runner Controller (self-hosted runners) |

## Development

```bash
tofu fmt -recursive    # format
# validate an individual module:
cd k8s/namespace && tofu init -backend=false && tofu validate
```

A secret scan (e.g. [`gitleaks`](https://github.com/gitleaks/gitleaks)) is
recommended in CI to keep credentials out of the tree.

## License

[MIT](./LICENSE).
