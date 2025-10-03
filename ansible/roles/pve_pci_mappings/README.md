pve_pci_mappings role
=====================

Purpose
-------
Ensure PCI passthrough mappings exist in Proxmox's /etc/pve/datacenter.cfg on a selected PVE host.

Usage
-----
Include the role in a play that targets a proxmox host group. Example in `site.yml`:

  - include_role:
      name: pve_pci_mappings

Variables
---------
- `pve_pci_mappings_list` (list) - list of mappings. Each item should have `name`, `host`, `path`.
- `pve_pci_mappings_force_create_datacenter_cfg` (bool) - if true, role will create `/etc/pve/datacenter.cfg` when missing (use with caution).

Backwards compatibility
-----------------------
The role attempts to read legacy variables `pve_pci_mappings` and `force_create_datacenter_cfg` if the prefixed ones are not set.

Notes
-----
- The role delegates changes to the first host in the `pve` group by default. Override with `pve_delegate` if needed.
- The role will fail early if `/etc/pve` is not present on the target host unless forced.
