# Proxmox Post-Install Role

This role performs common post-installation tasks for Proxmox VE servers.

## Features

- Configures Debian and Proxmox repositories
- Disables enterprise repository and enables no-subscription repository
- Disables the subscription nag in the web UI
- Configures high availability services
- Updates the system
- Enables PCI passthrough capabilities
- Configures IOMMU settings
- Sets up PCI resource mappings for VMs
- Sets up datacenter resource mappings
- Installs and configures fan control service

## Requirements

- Proxmox VE 8.x (Debian Bookworm)
- Ansible 2.9 or higher

## Role Variables

All variables are defined in `defaults/main.yml` and can be overridden.

```yaml
# Repository management
proxmox_correct_sources: true           # Update main Debian sources.list
proxmox_disable_enterprise_repo: true   # Disable enterprise repository
proxmox_enable_no_subscription_repo: true  # Enable no-subscription repository
proxmox_correct_ceph_sources: true      # Correct ceph repository sources
proxmox_add_pvetest_repo: false         # Add pvetest repository (disabled by default)

# Subscription nag
proxmox_disable_subscription_nag: true  # Remove subscription nag from web UI

# High availability settings
proxmox_enable_ha: false               # Enable HA cluster services
proxmox_disable_ha: false              # Disable HA cluster services

# Updates
proxmox_update: true                   # Perform system update

# PCI passthrough settings
proxmox_enable_passthrough: true        # Enable PCI passthrough
proxmox_passthrough_modules:            # Kernel modules for passthrough
  - vfio
  - vfio_iommu_type1
  - vfio_pci
  - vfio_virqfd
proxmox_iommu_parameters: "intel_iommu=on iommu=pt"  # IOMMU parameters

# PCI passthrough resource mappings
proxmox_pci_resource_mappings: []      # Resource mappings for PCI passthrough
# Example format:
# proxmox_pci_resource_mappings:
#   - vm_id: "100"                     # VM ID to map the PCI device to
#     host_pci_id: "0000:00:1f.0"      # Host PCI device ID
#     mapping_name: "0"                # Mapping name (usually a number)
#     device_options:                  # Optional device parameters
#       pcie: 1
#       rombar: 0
#   - vm_id: "101"
#     host_pci_id: "0000:01:00.0"
#     mapping_name: "0"
#     device_options:
#       mdev: "nvidia-22"

# Datacenter resource mappings
proxmox_resource_mappings: []           # Resource mappings for the datacenter
# Example format:
# proxmox_resource_mappings:
#   - id: "HBA_01"                     # Resource mapping ID/name
#     type: "pci"                       # Resource type (pci, usb, etc.)
#     node: "proxmox"                   # Proxmox node name
#     pci_device: "0000:01:00.0"        # PCI device address
#     description: "LSI HBA Controller" # Optional description

# Fan control settings
proxmox_enable_fancontrol: false       # Whether to enable fan control
proxmox_fancontrol_script_path: "/opt/fancontrol/fancontrol.sh"  # Path to fan control script

# Reboot after configuration
proxmox_reboot: false                  # Whether to reboot after configuration
```

## Example Playbook

```yaml
- hosts: proxmox
  become: true
  roles:
    - role: proxmox_post_install
      vars:
        proxmox_reboot: true  # Enable reboot after configuration
        proxmox_pci_resource_mappings:
          - vm_id: "100"
            host_pci_id: "0000:01:00.0"
            mapping_name: "0"
            device_options:
              pcie: 1
              rombar: 0
          - vm_id: "101"
            host_pci_id: "0000:02:00.0"
            mapping_name: "0"
            device_options:
              pcie: 1
        proxmox_resource_mappings:
          - id: "HBA_01"
            type: "pci"
            node: "proxmox"
            pci_device: "0000:03:00.0"
            description: "LSI HBA Controller"
          - id: "GPU_01"
            type: "pci"
            node: "proxmox"
            pci_device: "0000:01:00.0"
            description: "NVIDIA GPU"
```

## License

MIT

## Author Information

Created by Your Name.
