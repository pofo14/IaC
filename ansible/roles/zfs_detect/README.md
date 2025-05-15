# Role Name: zfs_detect

## Description
This role ensures that a specified ZFS pool exists before running Proxmox configuration.

- If the pool already exists, it sets an empty disk list (`[]`).
- If the pool does not exist, it attempts to import it.
- If the import fails, the role safely fails with a clear message.
- Sets a dynamic fact `dynamic_zfs_disks` for downstream use.

## Variables

| Variable | Default | Description |
|:---------|:--------|:------------|
| `zfs_pool_name` | `vmdata` | Name of the ZFS pool to detect/import. |
| `zfs_disks` | `[]` | List of disks to use if pool creation is needed. |

## Example Usage

```yaml
- hosts: pve_nodes
  roles:
    - role: zfs_detect
    - role: lae.proxmox
      vars:
        proxmox_zfs_pools:
          - name: "{{ zfs_pool_name }}"
            state: present
            disks: "{{ dynamic_zfs_disks }}"
