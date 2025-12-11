# Blank VM Module for Preseed Testing
# Creates a VM with multiple empty disks (no cloning, no cloud-init)
# Designed for PXE/ISO boot with automated preseed installations

resource "proxmox_virtual_environment_vm" "vm_blank" {
  name        = var.hostname
  node_name   = var.proxmox_host
  tags        = length(var.tags) > 0 ? var.tags : ["preseed", "test"]
  description = var.description

  # VM hardware configuration
  machine = var.machine
  bios    = var.bios

  agent {
    enabled = var.qemu_agent_enabled
  }

  cpu {
    cores   = var.cores
    sockets = var.sockets
    type    = var.cpu_type
  }

  memory {
    dedicated = var.memory
    floating  = var.memory
  }

  # Create multiple disks based on the disks variable
  dynamic "disk" {
    for_each = var.disks
    content {
      datastore_id = disk.value.datastore_id
      interface    = disk.value.interface # e.g., "scsi0", "scsi1" for predictable IDs
      size         = disk.value.size
      file_format  = disk.value.file_format
      cache        = lookup(disk.value, "cache", "none")
      discard      = lookup(disk.value, "discard", "on")
      iothread     = lookup(disk.value, "iothread", false)
      ssd          = lookup(disk.value, "ssd", false)
    }
  }

  # SCSI controller configuration
  scsi_hardware = var.scsi_hardware

  # Network device
  network_device {
    bridge      = var.network_bridge
    mac_address = var.mac_address
  }

  # Optional: static network configuration via initialization (without cloud-init user-data)
  dynamic "initialization" {
    for_each = var.enable_network_config ? [1] : []
    content {
      dynamic "ip_config" {
        for_each = var.ipaddress != "" && var.ipaddress != "dhcp" ? [1] : []
        content {
          ipv4 {
            address = var.ipaddress
            gateway = var.gateway
          }
        }
      }

      dynamic "ip_config" {
        for_each = var.ipaddress == "" || var.ipaddress == "dhcp" ? [1] : []
        content {
          ipv4 {
            address = "dhcp"
          }
        }
      }
    }
  }

  # Don't start the VM automatically - user will attach ISO and boot manually
  started = var.start_on_create

  lifecycle {
    ignore_changes = [
      started, # Allow manual stop/start without Terraform interference
    ]
  }
}
