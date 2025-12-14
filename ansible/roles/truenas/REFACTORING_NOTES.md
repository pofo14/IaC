# TrueNAS Role Refactoring Notes

**Date:** December 13, 2025
**Branch:** feature/terraform-refactor

## Summary

Refactored the `truenas` role to fully leverage the `arensb.truenas` Ansible collection and remove redundant custom implementations.

---

## Changes Made

### 1. Dataset Management (`tasks/datasets.yml`)

**Previous Implementation:**

- Mixed approach using `arensb.truenas.dataset` for one dataset
- Custom URI calls to verify dataset existence
- SSH-based directory creation with shell commands
- Complex block/rescue error handling
- **73 lines of complex code**

**New Implementation:**

- Uses `arensb.truenas.filesystem` module for all dataset creation
- Supports ZFS properties: compression, atime, recordsize, sync, quota
- Uses TrueNAS API's `/filesystem/setperm` endpoint for directory permissions
- Cleaner, more maintainable code
- **41 lines of declarative code**

**Benefits:**

- ✅ Idempotent dataset creation
- ✅ Proper ZFS property management
- ✅ No SSH dependency for datasets
- ✅ Built-in error handling from collection module
- ✅ Easier to extend and maintain

### 2. Archived Custom Modules (`archive/library/`)

Moved unused custom modules to archive:

#### `truenas_disk_map.py`

- **Purpose:** Map disk serial numbers to TrueNAS disk names for ZFS pool creation
- **Status:** Never called in any playbooks
- **Reason for archival:** Related to automated pool creation (which was removed)

#### `truenas_system.py`

- **Purpose:** Manage TrueNAS system settings (hostname, domain) via WebSocket API
- **Status:** Replaced by `arensb.truenas.hostname` and `arensb.truenas.domain`
- **Reason for archival:** Redundant - collection provides superior maintained modules

---

## Role Capabilities

The `truenas` role now properly manages:

| Feature | Module Used | Status |
|---------|-------------|--------|
| Hostname | `arensb.truenas.hostname` | ✅ Collection |
| Domain | `arensb.truenas.domain` | ✅ Collection |
| Services | `arensb.truenas.service` | ✅ Collection |
| Datasets | `arensb.truenas.filesystem` | ✅ Collection |
| Dataset permissions | `ansible.builtin.uri` (API) | ✅ Custom (necessary) |
| NFS shares | `arensb.truenas.sharing_nfs` | ✅ Collection |
| S.M.A.R.T. | `arensb.truenas.smart_test_task` | ✅ Collection |
| ZFS pools | ❌ Manual via UI | Intentional |

---

## Container Deployment Strategy

### Research Findings

**TrueNAS SCALE Container Technologies:**

1. **Docker/Docker Compose** - ✅ Production-ready, fully supported, native to SCALE
2. **LXC Containers** - ⚠️ Experimental (25.04+), UI-only, not recommended for production
3. **K3s/Apps** - ❌ Removed in TrueNAS 24.10

### Current Implementation (Correct)

**Monitoring Exporters:** Use Docker Compose via `truenas_monitoring_exporters` role

- `ansible.builtin.docker_compose` module
- Deploys: node_exporter, zfs_exporter, smartctl_exporter
- **This is the correct TrueNAS-native approach**

**Why Docker Compose is Correct:**

- ✅ TrueNAS SCALE includes native Docker daemon
- ✅ Production-ready and stable
- ✅ Ansible automation via `community.docker` collection
- ✅ Declarative, version-controlled deployments
- ✅ Survives system upgrades
- ✅ Handles privileged container requirements

**arensb.truenas Collection:**

- ❌ Does NOT provide container/app deployment modules
- Focuses on TrueNAS system management (storage, sharing, services)
- Docker is standard Linux tooling - use community modules

---

## Variable Structure

### Dataset Configuration Example

```yaml
truenas_datasets:
  - path: tank/monitoring
    compression: lz4      # Optional, defaults to lz4
    atime: off           # Optional, defaults to off
    recordsize: 128K     # Optional
    quota: 107374182400  # Optional, in bytes (100GB)
    directories:         # Optional subdirectories
      - path: "logs"
        owner: "root"
        group: "wheel"
        mode: "0755"
      - path: "data"
        owner: "prometheus"
        group: "prometheus"
        mode: "0750"
```

### Monitoring Configuration Example

```yaml
truenas_monitoring_dataset_name: tank/monitoring
monitoring_docker_compose_dir: /opt/ansible/truenas_monitoring_exporters

node_exporter_image: prom/node-exporter:latest
node_exporter_port: 9100

zfs_exporter_image: quay.io/robustperception/zfs_exporter:latest
zfs_exporter_port: 9134

smartctl_exporter_image: prometheuscommunity/smartctl-exporter:latest
smartctl_exporter_port: 9631
```

---

## Testing

To test the refactored role:

```bash
# Check mode (dry run)
ansible-playbook site.yml --tags truenas --check -l truenas

# Apply to specific host
ansible-playbook site.yml --tags truenas -l truenas1.flopo.retropetro.net

# Test only dataset management
ansible-playbook site.yml --tags truenas,datasets -l truenas
```

---

## References

- **arensb.truenas Collection:** <https://github.com/arensb/ansible-truenas>
- **Collection Documentation:** <https://arensb.github.io/truenas/index.html>
- **TrueNAS SCALE Containers:** <https://www.truenas.com/docs/scale/scaletutorials/containers/>
- **TrueNAS API Documentation:** <https://www.truenas.com/docs/scale/api/>

---

## Migration Notes

If you have existing TrueNAS hosts:

1. **Datasets:** The new implementation is idempotent - it will only create missing datasets
2. **Properties:** Existing datasets won't be modified unless properties differ
3. **Directories:** The API-based permission setting is safe for existing directories
4. **No downtime:** Changes are non-disruptive

---

## Future Improvements

Potential enhancements:

1. Add snapshot management via `arensb.truenas.pool_snapshot_task`
2. Implement SMB share management via `arensb.truenas.sharing_smb`
3. Add user/group management via `arensb.truenas.user` and `arensb.truenas.group`
4. Consolidate monitoring into dedicated play (as planned in previous discussions)

---

## Author

Refactored by GitHub Copilot
Date: December 13, 2025
