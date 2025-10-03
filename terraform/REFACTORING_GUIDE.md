# Terraform Refactoring - Migration Guide

## Overview

This document outlines the refactoring performed on the Terraform infrastructure to separate infrastructure and workload concerns.

## What Changed

### Old Architecture (Deprecated)

```
terraform/environments/test/pve1/vm-test-truenas1/
└── Uses: truenas-pci-vm module
    ├── proxmox-datacenter-pci-mappings
    ├── vm-clone-bgp
    └── pve-pci-passthrough
```

**Problems:**
- Tight coupling between infrastructure and workloads
- Requires root credentials for all VM operations
- Can't reuse PCI mappings across VMs
- Complex dependency management

### New Architecture (Current)

```
terraform/environments/test/
├── infrastructure/
│   └── pve1/
│       └── pci-mappings/          # Apply FIRST with root
│           └── Uses: proxmox-datacenter-pci-mappings
└── workloads/
    └── pve1/
        └── vm-test-truenas1/      # Apply SECOND with API token
            └── Uses: vm-clone-bgp directly
```

**Benefits:**
- ✅ Clear separation of concerns
- ✅ Infrastructure managed independently
- ✅ PCI mappings reusable across multiple VMs
- ✅ Data source validation for dependencies
- ✅ Simpler module structure

## Migration Steps

### For Existing vm-test-truenas1

1. **Backup current state:**
   ```bash
   cd terraform/environments/test/pve1/vm-test-truenas1
   cp terraform.tfstate terraform.tfstate.backup
   ```

2. **Apply infrastructure layer:**
   ```bash
   cd ../../infrastructure/pve1/pci-mappings
   terraform init
   terraform apply
   ```

3. **Import existing VM to new workload layer:**
   ```bash
   cd ../../../workloads/pve1/vm-test-truenas1
   terraform init
   
   # Import the existing VM (get VM ID from old state)
   terraform import module.truenas_vm.proxmox_virtual_environment_vm.vm_clone <VM_ID>
   ```

4. **Verify and apply:**
   ```bash
   terraform plan  # Should show no changes
   terraform apply
   ```

5. **Clean up old directory:**
   ```bash
   # After verifying new setup works
   mv ../../pve1/vm-test-truenas1 ../../pve1/vm-test-truenas1.old
   ```

### For New Deployments

1. **Create PCI mappings in infrastructure layer**
2. **Create VM in workload layer referencing those mappings**
3. **See:** `terraform/environments/test/README.md` for detailed guide

## Module Changes

### ✅ Still Used

- **`vm-clone-bgp`** - Primary VM creation module (now includes PCI passthrough)
- **`proxmox-datacenter-pci-mappings`** - Infrastructure layer PCI mappings

### ⚠️ Deprecated

- **`truenas-pci-vm`** - Redundant wrapper, use `vm-clone-bgp` directly
- **`pve-pci-passthrough`** - Functionality moved into `vm-clone-bgp`

### 🔧 Fixed

**`proxmox-datacenter-pci-mappings/main.tf`:**
- Fixed `for_each` to use `m.name` instead of `m.path`
- Simplified resource structure

**`proxmox-datacenter-pci-mappings/variables.tf`:**
- Removed unused provider variables
- Added `name` field to `pci_mappings` object
- Simplified to essential variables only

## File Structure Changes

### New Files Created

```
terraform/environments/test/
├── infrastructure/pve1/pci-mappings/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── outputs.tf
│   └── provider.tf
├── workloads/pve1/vm-test-truenas1/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── data.tf
│   ├── outputs.tf
│   └── provider.tf
└── README.md (comprehensive documentation)
```

### Files to Deprecate

```
terraform/environments/test/pve1/vm-test-truenas1/
└── (entire old directory - can be archived)
```

## Key Design Decisions

### 1. Proxmox Host-Level Mappings = Infrastructure Layer

**Answer:** YES, separate from VM creation

**Rationale:**
- PCI mappings are host/datacenter configuration
- Require elevated privileges
- Should be stable and rarely changed
- Reusable across multiple VMs

### 2. Is truenas-pci-vm Module Needed?

**Answer:** NO, it's redundant

**Rationale:**
- `vm-clone-bgp` already supports PCI passthrough
- Wrapper adds unnecessary complexity
- Direct module usage is clearer

### 3. Implications for proxmox-datacenter-pci-mappings

**Answer:** Use in infrastructure layer only

**Changes Made:**
- Fixed `for_each` logic
- Simplified variables
- Enhanced outputs
- Use separately from VM creation

## Dependency Management Strategy

### Data Source Validation (Chosen Approach)

```hcl
# In workload layer
data "proxmox_virtual_environment_hardware_mapping_pci" "required_mappings" {
  for_each = toset(var.required_pci_mappings)
  name     = each.value
}
```

**Why:**
- Fails fast with clear errors
- Self-documenting dependencies
- No shared state complexity
- Can still apply layers independently

### Deployment Order Enforcement

1. **Documentation** - Clear README with deployment steps
2. **Data Sources** - Validate infrastructure exists
3. **CI/CD** - (Future) Pipeline enforces order automatically

## Rollback Plan

If issues occur:

1. **Keep old directory intact** until new setup is verified
2. **State can be restored** from backup
3. **PCI mappings** are idempotent (safe to reapply)
4. **VMs** can be imported into new structure

## Testing Checklist

Before considering migration complete:

- [ ] Infrastructure layer applies successfully
- [ ] Workload layer recognizes PCI mappings
- [ ] VM boots with PCI devices attached
- [ ] Can run `terraform plan` without changes
- [ ] Outputs are correct
- [ ] Documentation is clear

## Next Steps

1. **Test Environment** - Verify new structure works (DONE)
2. **Production Environment** - Apply same pattern to `environments/prod/`
3. **Other Workloads** - Migrate other VMs using similar pattern
4. **CI/CD** - Implement pipeline to enforce deployment order
5. **Cleanup** - Archive deprecated modules after migration complete

## Questions & Support

For questions about this refactoring:
1. Review `terraform/environments/test/README.md`
2. Check module documentation in `terraform/modules/*/README.md`
3. Examine example configurations in new structure

## Summary

| Aspect | Old | New |
|--------|-----|-----|
| **Structure** | Single layer | Infrastructure + Workload |
| **Modules** | truenas-pci-vm wrapper | Direct vm-clone-bgp usage |
| **Credentials** | Root for everything | Root for infra, token for workloads |
| **PCI Mappings** | Per-VM creation | Centralized, reusable |
| **Dependencies** | Implicit in module | Explicit via data sources |
| **Complexity** | High coupling | Clear separation |
| **Reusability** | Low | High |
