# Ansible Role: TrueNAS Monitoring Exporters

This role deploys a monitoring stack for TrueNAS using Docker Compose. It includes:
- Node Exporter for system-level metrics.
- ZFS Exporter for ZFS pool and dataset metrics.
- Smartctl Exporter for S.M.A.R.T. disk health metrics.

## Requirements

- Ansible 2.12+
- Target host must be TrueNAS Scale (for native Docker support).
- Docker must be installed on the TrueNAS Scale host. This role assumes Docker is either pre-installed or managed by another role (e.g., `geerlingguy.docker`, which has been included in the main site playbook for the `truenas` host group).
- The `arensb.truenas` Ansible collection (for dataset management by the `truenas` role).

## Role Variables

The following variables are used by this role, typically defined in group or host variables (e.g., `inventory/group_vars/truenas.yml`):

- `truenas_monitoring_dataset_name`: The ZFS dataset where monitoring configurations might be stored or that this stack is associated with (e.g., `tank/monitoring`). *Currently, this role doesn't store anything in this dataset but the dataset creation is handled by the `truenas` role.*
- `node_exporter_image`: Docker image for Node Exporter. (Default: `prom/node-exporter:latest`)
- `node_exporter_port`: Host port for Node Exporter. (Default: `9100`)
- `zfs_exporter_image`: Docker image for ZFS Exporter. (Default: `quay.io/robustperception/zfs_exporter:latest`)
- `zfs_exporter_port`: Host port for ZFS Exporter. (Default: `9134`)
- `smartctl_exporter_image`: Docker image for Smartctl Exporter. (Default: `prometheuscommunity/smartctl-exporter:latest`)
- `smartctl_exporter_port`: Host port for Smartctl Exporter. (Default: `9631`)
- `monitoring_docker_compose_dir`: Path on the TrueNAS host to store the `docker-compose.yml` file for this stack. (Default: `/opt/ansible/truenas_monitoring_exporters`)

This role also optionally updates Prometheus target files on the Ansible controller (localhost) if the `prometheus_update` tag is active. The target files are:
- `{{ inventory_dir }}/group_vars/all/node_exporters_truenas.yml`
- `{{ inventory_dir }}/group_vars/all/zfs_exporters_truenas.yml`
- `{{ inventory_dir }}/group_vars/all/smartctl_exporters_truenas.yml`

## Dependencies

- Implicit dependency on Docker being available on the TrueNAS host.
- The `truenas` role (or similar) should be used to create the `truenas_monitoring_dataset_name` if specific configurations were to be stored there by this role in the future.

## Example Playbook Inclusion

```yaml
- name: Configure TrueNAS Server
  hosts: truenas
  # ... other play settings ...

  roles:
    - role: truenas # Handles dataset creation
    - role: geerlingguy.docker # Ensures Docker is installed
      become: true
    - role: truenas_monitoring_exporters
```

## Functionality

1.  **Templates Docker Compose File**: Creates a `docker-compose.yml` file in `{{ monitoring_docker_compose_dir }}` on the TrueNAS host, defining the exporter services.
2.  **Manages Services**: Uses `ansible.builtin.docker_compose` to ensure the defined services are running.
3.  **Prometheus Integration (Optional)**: If enabled (default), updates YAML files on the Ansible controller that can be used for Prometheus `file_sd_configs`.

## Notes on Exporters

-   **Node Exporter**: Runs with `pid: "host"` and mounts `/` as `/host` to access host metrics.
-   **ZFS Exporter**: The provided image `quay.io/robustperception/zfs_exporter` should work on TrueNAS Scale without special privileges if run on the ZFS host.
-   **Smartctl Exporter**: This exporter requires `privileged: true` and mounts `/dev` as `/host/dev` to access disk S.M.A.R.T. data. This is the most likely component to require adjustments based on your specific TrueNAS hardware and disk setup. Check its logs carefully (`docker logs smartctl_exporter`). You might need to pass specific device names or options via the `environment` section in the `templates/docker-compose.yml.j2` if auto-discovery doesn't work as expected.

## License

Specify your license (e.g., MIT, GPLv3).

## Author Information

Your Name / Your Org.
