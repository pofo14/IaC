# Ansible Role: TrueNAS

Manages TrueNAS SCALE configuration using the `arensb.truenas` Ansible collection.

## Description

This role configures TrueNAS SCALE systems via the TrueNAS middleware API. It handles system settings, datasets, services, NFS shares, and S.M.A.R.T. configuration.

## Requirements

- **TrueNAS SCALE** (tested on 24.10+, 25.04+)
- **Ansible 2.12+**
- **arensb.truenas collection** (install via `ansible-galaxy collection install arensb.truenas`)
- TrueNAS API credentials (username/password or API key)

## Role Variables

See [`defaults/main.yml`](defaults/main.yml) for all available variables.

### Core Variables

```yaml
# System configuration
truenas_hostname: "truenas"
truenas_domain: "example.com"

# API authentication
truenas_api_protocol: "http"  # or https
truenas_api_port: 80          # or 443 for https
truenas_api_key: "{{ vault_truenas_api_key }}"  # Recommended: store in Ansible Vault
```

### Services

```yaml
truenas_services:
  - name: "ssh"
    enabled: true
    state: started
  - name: "nfs"
    enabled: true
    state: started
  - name: "smartd"
    enabled: true
    state: started
```

### Datasets

```yaml
truenas_datasets:
  - path: "tank/media"
    compression: "lz4"       # Optional: compression algorithm
    atime: "off"             # Optional: access time updates
    recordsize: "1M"         # Optional: record size
    quota: 107374182400      # Optional: quota in bytes (100GB)
    directories:             # Optional: subdirectories with permissions
      - path: "movies"
        owner: "media"
        group: "media"
        mode: "0755"
      - path: "tv"
        owner: "media"
        group: "media"
        mode: "0755"
```

### NFS Configuration

```yaml
truenas_nfs:
  v4: true
  allow_nonroot: true
  shares:
    - path: "/mnt/tank/media"
      comment: "Media share"
      networks: ["192.168.1.0/24"]
      hosts: []
      ro: false
      mapall_user: "media"
      mapall_group: "media"
```

### S.M.A.R.T. Configuration

```yaml
truenas_smart:
  power_mode: "never"      # never, sleep, standby, idle
  temp_difference: 2       # Temperature change to log
  temp_info: 40           # Info level temperature
  temp_crit: 45           # Critical temperature
```

## Dependencies

- `arensb.truenas` collection

## Example Playbook

```yaml
- name: Configure TrueNAS Server
  hosts: truenas
  gather_facts: false
  become: false
  environment:
    middleware_method: midclt  # Use midclt communication method

  collections:
    - arensb.truenas

  roles:
    - role: truenas
      tags: truenas
```

## Tags

The role supports the following tags:

- `truenas` - Run all tasks
- `hostname` - Configure hostname only
- `domain` - Configure domain only
- `services` - Configure services only
- `datasets` - Manage datasets and directories
- `nfs` - Configure NFS shares
- `smart` - Configure S.M.A.R.T. settings

### Tag Usage Examples

```bash
# Run all TrueNAS configuration
ansible-playbook site.yml --tags truenas

# Configure only datasets
ansible-playbook site.yml --tags truenas,datasets

# Configure NFS shares only
ansible-playbook site.yml --tags truenas,nfs

# Skip dataset management
ansible-playbook site.yml --tags truenas --skip-tags datasets
```

## Features

### What This Role Does

✅ Configure system hostname and domain
✅ Manage system services (SSH, NFS, SMB, S.M.A.R.T.)
✅ Create and configure ZFS datasets with properties
✅ Set directory permissions within datasets
✅ Configure NFS shares and settings
✅ Configure S.M.A.R.T. monitoring

### What This Role Does NOT Do

❌ **ZFS pool creation** - Create pools manually via TrueNAS UI
❌ **Container/app deployment** - Use separate `truenas_monitoring_exporters` role
❌ **User/group management** - Can be added if needed
❌ **Snapshots** - Can be added using `arensb.truenas.pool_snapshot_task`

## Architecture

The role uses the `arensb.truenas` collection which communicates with TrueNAS via:

1. **Primary method:** TrueNAS middleware API (REST)
2. **Alternative method:** `midclt` CLI utility (set via `middleware_method` environment variable)

All tasks are executed via API calls - no SSH required to the TrueNAS system.

## Directory Structure

```
truenas/
├── defaults/
│   └── main.yml          # Default variables
├── tasks/
│   ├── main.yml          # Main task orchestration
│   ├── hostname.yml      # Hostname configuration
│   ├── domain.yml        # Domain configuration
│   ├── services.yml      # Service management
│   ├── datasets.yml      # Dataset and directory management
│   ├── nfs.yml           # NFS share configuration
│   └── smart.yml         # S.M.A.R.T. configuration
├── archive/
│   └── library/          # Archived custom modules
├── REFACTORING_NOTES.md  # Detailed refactoring documentation
└── README.md             # This file
```

## Testing

### Check Mode (Dry Run)

```bash
# Test all changes without applying
ansible-playbook site.yml --tags truenas --check -l truenas

# Test specific tasks
ansible-playbook site.yml --tags truenas,datasets --check -l truenas
```

### Verbose Output

```bash
# Show detailed API calls and responses
ansible-playbook site.yml --tags truenas -l truenas -vvv
```

### Limit to Specific Host

```bash
# Run only on specific TrueNAS host
ansible-playbook site.yml --tags truenas -l truenas1.flopo.retropetro.net
```

## Troubleshooting

### API Connection Issues

If you see connection errors:

1. Verify TrueNAS API is accessible:

   ```bash
   curl -k https://truenas-host/api/v2.0/system/general
   ```

2. Check credentials in inventory:

   ```yaml
   [truenas]
   truenas1.flopo.retropetro.net ansible_user=root
   ```

3. Verify vault variables are decrypted:

   ```bash
   ansible-vault view inventories/production/group_vars/truenas/vault.yml
   ```

### Module Not Found Errors

If you see `module not found` errors:

```bash
# Install/update the collection
ansible-galaxy collection install arensb.truenas --force

# Verify installation
ansible-galaxy collection list | grep truenas
```

### Dataset Creation Fails

If dataset creation fails:

1. Verify the parent pool exists
2. Check pool has available space: `zfs list`
3. Ensure dataset path follows format: `pool/dataset/nested`
4. Use `--check` mode first to validate

## Performance Notes

- Dataset operations are idempotent - safe to run repeatedly
- Directory permission changes use TrueNAS API (no SSH overhead)
- Services are only restarted when configuration changes

## Security

- Store API credentials in Ansible Vault
- Use API keys instead of passwords when possible
- Limit API user permissions to minimum required
- Use HTTPS for API communication in production

## References

- **arensb.truenas Collection:** <https://github.com/arensb/ansible-truenas>
- **Collection Docs:** <https://arensb.github.io/truenas/index.html>
- **TrueNAS SCALE Docs:** <https://www.truenas.com/docs/scale/>
- **TrueNAS API Docs:** <https://www.truenas.com/docs/scale/api/>

## License

MIT

## Author Information

Role maintained as part of IaC repository.
Refactored: December 13, 2025
