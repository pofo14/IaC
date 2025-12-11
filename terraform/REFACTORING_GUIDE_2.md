# Terraform Refactoring Plan

> **Goal:** Migrate from mixed workload/infrastructure structure to a clean node-per-environment architecture

## 📊 Current State Analysis

### Problems Identified

1. **Inconsistent Organization**
   - Some configs organized by workload type (`vm-truenas1/`, `vm-opnsense/`)
   - Some organized by node (`workloads/pve1/`)
   - No clear pattern

2. **Provider Duplication**
   - `providers.tf` repeated in ~15 directories
   - Authentication credentials scattered

3. **Mixed Concerns**
   - PCI mappings mixed with VM definitions
   - Infrastructure and workloads in same state file

4. **State File Sprawl**
   - Multiple small state files (`lxc-pihole`, `vm-truenas1`)
   - Some large monolithic files (`workloads/pve1`)

5. **Module Underutilization**
   - Modules exist but aren't consistently used
   - Direct resource blocks duplicated across configs

## 🎯 Target Architecture

```
environments/{env}/
├── infrastructure/{node}/    # Node-level: PCI, storage, networks
│   ├── main.tf              # Infrastructure resources
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── backend.tf
└── workloads/{node}/        # Compute: VMs, LXCs, templates
    ├── main.tf              # Workload resources
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars
    └── backend.tf
```

### Design Principles

1. **Separation of Concerns**
   - Infrastructure = hardware/storage/network configuration
   - Workloads = VMs/LXCs that run on the infrastructure

2. **One Node Per Directory**
   - Each Proxmox node (`pve1`, `pve2`, `pve3`) has its own folder
   - Per environment (`dev`, `test`, `stage`, `prod`)

3. **Module-First**
   - All VMs use `vm-clone-bgp` or `vm-iso-bgp` modules
   - All LXCs use `lxc-template` or `lxc-clone` modules
   - No raw `proxmox_vm_qemu` resources

4. **Explicit Dependencies**
   - Workloads can reference infrastructure via `terraform_remote_state`
   - Clear dependency chain: infrastructure → workloads

## 🔄 Migration Strategy

### Phase 1: Create New Structure (Week 1)

#### Step 1.1: Generate Directory Tree

```bash
#!/bin/bash
# filepath: /workspaces/IaC/terraform/scripts/generate-structure.sh

ENVIRONMENTS=("dev" "test" "stage" "prod")
NODES=("pve1" "pve2" "pve3")

for env in "${ENVIRONMENTS[@]}"; do
  for node in "${NODES[@]}"; do
    # Infrastructure
    mkdir -p "environments/${env}/infrastructure/${node}"

    # Workloads
    mkdir -p "environments/${env}/workloads/${node}"
  done
done

echo "✅ Directory structure created"
```

#### Step 1.2: Create Shared Configuration

```bash
mkdir -p shared
```

````hcl
// filepath: /workspaces/IaC/terraform/shared/providers.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9.11"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
  pm_parallel         = 2
  pm_timeout          = 600
}
