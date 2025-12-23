# Terraform Workloads - Usage Guide

## Architecture

This directory uses a **locals-based architecture** for VM definitions:

```
pve01/
├── main.tf         # Module calls (uses locals)
├── locals.tf       # VM definitions as data structures
├── variables.tf    # Shared infrastructure variables
├── outputs.tf      # All VM outputs
├── provider.tf     # Provider configuration
└── cloud-init/     # Cloud-init templates
    ├── cloud-init-docker.yml
    └── cloud-init-management.yml
```

## Benefits

- ✅ **Scalable**: Add VMs by editing `locals.tf` only
- ✅ **DRY**: Shared config in variables, VM-specific in locals
- ✅ **Maintainable**: VM groups use `for_each` for consistency
- ✅ **Clear**: Each file has a single responsibility

## Adding a New VM

### Option 1: Add to Existing Group (Docker/Management)

Edit [locals.tf](locals.tf) and add a new entry:

```hcl
docker_hosts = {
  docker01 = { ... }
  docker02 = { ... }
  docker03 = {  # ← Add this
    hostname    = "docker03"
    ipaddress   = "10.10.10.13/24"
    template_id = var.ubuntu24_template_id
    cores       = 4
    memory      = 8192
    disksize    = "100"
    # ... rest of config
  }
}
```

### Option 2: Create New VM Group

1. **Define VMs in [locals.tf](locals.tf):**

```hcl
database_vms = {
  postgres = {
    hostname    = "postgres"
    ipaddress   = "10.10.10.20/24"
    template_id = var.ubuntu24_template_id
    cores       = 4
    memory      = 16384
    disksize    = "200"
    pci_mappings   = []
    add_extra_disk = false
    extra_disks    = []
    cloud_init_enabled = true
    cloud_init_file    = "cloud-init-database.yml"
    tags        = ["database", "postgres", "prod"]
    description = "PostgreSQL Database Server"
  }
}
```

1. **Add module call in [main.tf](main.tf):**

```hcl
module "database-vms" {
  for_each = local.database_vms
  source   = "../../../../modules/vm-clone-bgp"

  proxmox_host = var.proxmox_host
  template_id  = each.value.template_id
  storage_pool = var.storage_pool

  hostname  = each.value.hostname
  domain    = var.domain
  ipaddress = each.value.ipaddress
  gateway   = var.gateway

  cores    = each.value.cores
  sockets  = each.value.sockets
  cpu_type = each.value.cpu_type
  memory   = each.value.memory
  disksize = each.value.disksize

  pci_mappings   = each.value.pci_mappings
  add_extra_disk = each.value.add_extra_disk
  extra_disks    = each.value.extra_disks

  tags        = each.value.tags
  description = each.value.description

  cloud_init_content = each.value.cloud_init_enabled ? templatefile(
    "${path.module}/cloud-init/${each.value.cloud_init_file}",
    {
      hostname = each.value.hostname
      ssh_keys = local.github_ssh_keys
    }
  ) : ""
}
```

1. **Add outputs in [outputs.tf](outputs.tf):**

```hcl
output "database_vms" {
  description = "Summary of all Database VMs"
  value = {
    for key, vm in module.database-vms : key => {
      vm_id     = vm.vm_id
      vm_name   = vm.vm_name
      ipaddress = local.database_vms[key].ipaddress
      fqdn      = "${local.database_vms[key].hostname}.${var.domain}"
    }
  }
}
```

1. **Create cloud-init template** (if needed):

```bash
touch cloud-init/cloud-init-database.yml
```

## Deploying VMs

### Deploy Everything

```bash
terraform plan
terraform apply
```

### Deploy Specific VM Groups

```bash
# Only Docker hosts
terraform apply -target=module.docker-hosts

# Only Management VMs
terraform apply -target=module.management-vms

# Specific VM
terraform apply -target='module.docker-hosts["docker01"]'
```

### Destroy Specific VMs

```bash
# Remove one Docker host
terraform destroy -target='module.docker-hosts["docker02"]'

# Remove entire group
terraform destroy -target=module.docker-hosts
```

## Modifying VM Configuration

### Change Resources

Edit [locals.tf](locals.tf):

```hcl
docker01 = {
  # ...
  memory = 16384  # Changed from 8192 to 16384
  # ...
}
```

Then apply:

```bash
terraform plan  # Review changes
terraform apply
```

### Add/Remove from Group

**Add:** Just add new entry to map in [locals.tf](locals.tf)
**Remove:** Delete entry from map

Terraform will handle the changes automatically.

## Current Deployment

### VMs Defined

| VM | Group | IP | Resources |
|----|-------|----|-----------|
| files.flopo.retropetro.net | TrueNAS | 10.10.20.10/24 | 6c/64GB/128GB |
| docker01.flopo.retropetro.net | Docker | 10.10.10.11/24 | 4c/8GB/100GB |
| docker02.flopo.retropetro.net | Docker | 10.10.10.12/24 | 4c/8GB/100GB |
| management.flopo.retropetro.net | Management | 192.168.2.7/24 | 2c/2GB/64GB |

### Resource Totals

```bash
terraform output environment_summary
```

## Troubleshooting

### "Module not installed" Error

```bash
terraform init
```

### "Variable not declared" Error

- Check that variables are in [variables.tf](variables.tf)
- Check that VM configs reference `local.*` not `var.*` in main.tf/outputs.tf

### Validate Configuration

```bash
terraform fmt      # Format all files
terraform validate # Check syntax and references
```

## Best Practices

1. **Always edit [locals.tf](locals.tf) first** - Define VM before creating module
2. **Use descriptive hostnames** - They become DNS names
3. **Group similar VMs** - Use `for_each` for consistency
4. **Test with `terraform plan`** - Always review before apply
5. **Commit often** - Track changes in git
6. **Use tags** - For organization and cost tracking

## Migration from Old Structure

The old structure had individual variables for each VM:

```hcl
# OLD WAY ❌
variable "truenas_hostname" { default = "files" }
variable "truenas_memory" { default = 65536 }
variable "truenas_cores" { default = 6 }
# ... 50 more variables

module "truenas-files" {
  hostname = var.truenas_hostname
  memory   = var.truenas_memory
  cores    = var.truenas_cores
}
```

New structure uses locals as data structures:

```hcl
# NEW WAY ✅
locals {
  truenas_files = {
    hostname = "files"
    memory   = 65536
    cores    = 6
  }
}

module "truenas-files" {
  hostname = local.truenas_files.hostname
  memory   = local.truenas_files.memory
  cores    = local.truenas_files.cores
}
```

Benefits:

- **Less clutter**: 1 local block vs 50 variables
- **Easier to add VMs**: Edit 1 file, not 3-4 files
- **Clearer organization**: VMs grouped by purpose
- **Better defaults**: Sensible values in locals, not variables
