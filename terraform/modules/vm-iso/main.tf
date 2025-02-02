terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

resource "proxmox_vm_qemu" "vm-iso" {
  
  # General VM Settings
  target_node = var.proxmox_host
  name        = var.vm_name 

  # disk for iso mount
  disks {
    ide {
      ide2 {
        cdrom {
          iso = var.iso
        }
      }
    }
  } 
  
  desc        = var.desc
  tags        = var.tags

  # VM Advanced General Settings
  onboot = true

  # full_clone  = false
  agent       = 1
  cores       = var.cores
  sockets     = var.sockets
  cpu         = "host"

  memory      = var.memory
  scsihw      = "virtio-scsi-pci"

  disk {
    storage  = var.storage_pool
    type     = "disk" 
    size     = var.disksize
    slot     = "virtio0"
  }

  boot = "order=virtio0"

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  nameserver = var.nameserver
  searchdomain = var.searchdomain

  # VM Cloud-Init Settings
  os_type     = "cloud-init"  
  ipconfig0   = var.ipaddress

  # Default User
  ciuser = var.ciuser
  #cipassword = var.cipassword

  # SSH Key
  sshkeys = var.ssh_keys


}

