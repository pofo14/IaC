# ============================================================================
# PCI Device Mappings - Datacenter Level Configuration
# ============================================================================
# Creates PCI device mappings at the Proxmox datacenter level
# These mappings allow VMs to use physical PCI devices via passthrough
# ============================================================================

# ----------------------------------------------------------------------------
# HBA Controller Mapping
# ----------------------------------------------------------------------------
# LSI SAS 9300-8i HBA Controller for TrueNAS direct disk access
# This must be in IT (Initiator Target) mode, not IR/RAID mode

resource "proxmox_virtual_environment_hardware_mapping_pci" "hba_lsi_sas" {
  comment = "Broadcom / LSI SAS2308 PCI-Express Fusion-MPT SAS-2 for TrueNAS Files VM - Direct disk access for ZFS"
  name    = "hba-lsi-sas-9300-8i"

  # PCI device identification
  # Find with: lspci -nn | grep LSI
  # Example output: 01:00.0 Serial Attached SCSI controller [0107]: Broadcom / LSI SAS3008 PCI-Express Fusion-MPT SAS-3 [1000:0097]
  map = [
    {
      node = "pve01"

      # Device ID format: vendor:device
      # LSI/Broadcom SAS3008 = 1000:0097
      # You may need to adjust these values based on your actual hardware
      # Run: lspci -nn | grep -i sas
      id = "1000:0087" # Vendor:Device ID

      # PCI path - get from: lspci -D
      # Example: 0000:01:00.0
      path         = "0000:82:00.0" # PCI bus path - ADJUST TO YOUR HARDWARE
      subsystem_id = "1000:3020"    # Subsystem Vendor:Device ID
      iommu_group  = 15
    }
  ]
}

# ============================================================================
# Additional PCI Device Examples (commented out)
# ============================================================================

# ----------------------------------------------------------------------------
# Example: GPU Passthrough
# ----------------------------------------------------------------------------
# Uncomment and adjust for GPU passthrough to VMs

# resource "proxmox_virtual_environment_hardware_mapping_pci" "gpu_intel" {
#   comment = "Intel Integrated GPU for hardware transcoding"
#   name    = "gpu-intel-igpu"
#
#   map {
#     comment = "Intel UHD Graphics on pve01"
#     node    = "pve01"
#     id      = "8086:9bc8"  # Intel UHD Graphics 630 - adjust to your model
#     path    = "0000:00:02.0"
#   }
#
#   mdev = false
# }

# ----------------------------------------------------------------------------
# Example: Network Card Passthrough
# ----------------------------------------------------------------------------
# Uncomment for dedicated NIC passthrough (e.g., 10GbE for NAS)

# resource "proxmox_virtual_environment_hardware_mapping_pci" "nic_10gbe" {
#   comment = "Intel X540 10GbE NIC for TrueNAS"
#   name    = "nic-intel-x540"
#
#   map {
#     comment = "Intel X540-AT2 on pve01"
#     node    = "pve01"
#     id      = "8086:1528"  # Intel X540
#     path    = "0000:02:00.0"
#   }
#
#   mdev = false
# }

# ============================================================================
# IMPORTANT NOTES
# ============================================================================
#
# 1. IOMMU MUST BE ENABLED
#    - Edit /etc/default/grub:
#      GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"
#      (use amd_iommu=on for AMD CPUs)
#    - Run: update-grub && reboot
#
# 2. VFIO MODULES
#    - Add to /etc/modules:
#      vfio
#      vfio_iommu_type1
#      vfio_pci
#      vfio_virqfd
#    - Update initramfs: update-initramfs -u -k all
#
# 3. FIND YOUR DEVICE IDs
#    - List all PCI devices: lspci -nn
#    - Find your device: lspci -nn | grep -i <device_name>
#    - Get domain:bus:slot.function: lspci -D
#
# 4. VERIFY IOMMU GROUPS
#    - Check groups: find /sys/kernel/iommu_groups/ -type l
#    - Devices in same IOMMU group must be passed through together
#
# 5. HBA FIRMWARE MODE
#    - HBAs must be in IT (Initiator Target) mode
#    - IR (Integrated RAID) mode won't work properly with ZFS
#    - Flash to IT mode if needed (check vendor documentation)
#
# ============================================================================
