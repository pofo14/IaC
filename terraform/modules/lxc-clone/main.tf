terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

resource "proxmox_lxc" "lxc-clone" {
  
  target_node  = var.proxmox_host
  hostname     = var.hostname
  clone        = var.clone_id  # ID of the container to clone
  full        = true   # Perform a full clone
  
  // Resource limits
  cores    = 2
  memory   = 1024
  swap     = 512
  
  // Root disk
  rootfs {
    storage = "zfs01"
    size    = "32G"
  }
  
  // Network configuration
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }

  start = true

  lifecycle {
    ignore_changes = all  # Ignore all changes after creation
    create_before_destroy = true
  }

  timeouts {
    create = "10m"  # Increase timeout for creation
  }
}

