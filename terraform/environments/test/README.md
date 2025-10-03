# Test Environment - Terraform Configuration

This directory contains the Terraform configuration for the test environment, organized into **Infrastructure** and **Workload** layers.

## Architecture

### Two-Layer Design

1. **Infrastructure Layer** (`infrastructure/`)
   - Host-level configuration that requires elevated privileges
   - PCI device mappings at the Proxmox datacenter level
   - Should be stable and rarely changed
   - Uses root/admin credentials

2. **Workload Layer** (`workloads/`)
   - Virtual machine definitions
   - Application deployments
   - References infrastructure resources via data sources
   - Uses standard API tokens

## Directory Structure

```
test/
├── infrastructure/
│   └── pve1/
│       └── pci-mappings/          # Datacenter PCI device mappings
│           ├── main.tf
│           ├── variables.tf
│           ├── terraform.tfvars
│           ├── outputs.tf
│           └── provider.tf
├── workloads/
│   └── pve1/
│       └── vm-test-truenas1/      # TrueNAS test VM
│           ├── main.tf
│           ├── variables.tf
│           ├── terraform.tfvars
│           ├── data.tf
│           ├── outputs.tf
│           └── provider.tf
└── secrets.enc.yml                # Encrypted secrets (SOPS)
```

## Deployment Order

**IMPORTANT**: Infrastructure layer must be deployed before workloads.

### Step 1: Deploy Infrastructure Layer

```bash
# Navigate to infrastructure directory
cd infrastructure/pve1/pci-mappings

# Initialize Terraform
terraform init

# Review changes
terraform plan

# Apply (requires root/elevated credentials)
terraform apply
```

### Step 2: Deploy Workload Layer

```bash
# Navigate to workload directory
cd ../../../workloads/pve1/vm-test-truenas1

# Initialize Terraform
terraform init

# Review changes
terraform plan

# Apply
terraform apply
```

## Dependency Management

The workload layer uses **data sources** to validate that required infrastructure exists:

```hcl
# In workloads/pve1/vm-test-truenas1/data.tf
data "proxmox_virtual_environment_hardware_mapping_pci" "required_mappings" {
  for_each = toset(var.required_pci_mappings)
  name     = each.value
}
```

This ensures:
- ✅ Clear error messages if infrastructure is missing
- ✅ Self-documenting dependencies
- ✅ Can still be applied separately
- ✅ No shared state complexity

## Key Design Decisions

### Why Separate Infrastructure and Workloads?

1. **Lifecycle Separation**: Infrastructure changes infrequently; workloads change often
2. **Permission Boundaries**: Infrastructure requires root; workloads use API tokens
3. **Blast Radius**: Limit impact of workload changes
4. **Reusability**: Multiple VMs can use the same PCI mappings

### Why Data Sources Instead of Remote State?

1. **Simplicity**: No remote state backend configuration needed
2. **Validation**: Fails fast with clear errors if dependencies missing
3. **Flexibility**: Can still apply layers independently
4. **Type Safety**: References are validated by provider

### Module Simplification

The old architecture used `truenas-pci-vm` which wrapped:
- `proxmox-datacenter-pci-mappings`
- `vm-clone-bgp`
- `pve-pci-passthrough`

The new architecture:
- **Infrastructure layer**: Uses `proxmox-datacenter-pci-mappings` directly
- **Workload layer**: Uses `vm-clone-bgp` directly with `pci_mappings` parameter
- **Removed**: `truenas-pci-vm` (redundant wrapper)
- **Removed**: `pve-pci-passthrough` (functionality moved to `vm-clone-bgp`)

## Common Operations

### Adding a New PCI Device

1. Edit `infrastructure/pve1/pci-mappings/terraform.tfvars`
2. Add the new device to the `pci_mappings` list
3. Apply infrastructure layer
4. Reference the new mapping name in workload configurations

### Creating a New VM with PCI Passthrough

1. Ensure required PCI mappings exist in infrastructure layer
2. Create new directory under `workloads/pve1/`
3. Use `vm-clone-bgp` module with `pci_mappings` parameter
4. Add data source validation for required mappings

### Destroying Resources

```bash
# Destroy workloads first
cd workloads/pve1/vm-test-truenas1
terraform destroy

# Then destroy infrastructure (optional)
cd ../../../infrastructure/pve1/pci-mappings
terraform destroy
```

## Secrets Management

Secrets are encrypted with SOPS and stored in `secrets.enc.yml`.

### Editing Secrets

```bash
# Edit encrypted file
sops secrets.enc.yml

# Encrypt new file
sops -e secrets.yml > secrets.enc.yml
```

### Required Secrets

- `pve1_fdqn`: Proxmox API endpoint
- `pve1_username`: Root username for infrastructure layer
- `pve1_password`: Root password for infrastructure layer
- `pve1_api_token_id`: API token ID for workload layer
- `pve1_api_token_secret`: API token secret for workload layer
- `github_token`: GitHub token for SSH key retrieval

## Troubleshooting

### Error: PCI mapping not found

**Cause**: Infrastructure layer not applied or mapping name mismatch

**Solution**:
1. Apply infrastructure layer first
2. Verify mapping name matches in both layers
3. Check `terraform output` from infrastructure layer

### Error: Permission denied

**Cause**: Wrong provider credentials for the layer

**Solution**:
- Infrastructure layer: Use root credentials
- Workload layer: Use API token credentials

### Planning Changes

Before making changes:
1. Run `terraform plan` in both layers
2. Review dependencies
3. Apply infrastructure changes first
4. Then apply workload changes

## Future Improvements

- [ ] Add CI/CD pipeline to enforce deployment order
- [ ] Remote state backend for team collaboration
- [ ] Automated testing of infrastructure layer
- [ ] Separate prod environment with same structure
