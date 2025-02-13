terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.14"  # Using stable version
    }
  }
}

resource "proxmox_lxc" "container" {
  target_node  = "proxmox"
  hostname     = "mealie-template"
  ostemplate   = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  password     = "Ch@rl!e29"
  unprivileged = true
  
  // Resource limits
  cores    = 2
  memory   = 1024
  swap     = 512
  
  // Root disk
  rootfs {
    storage = "local-zfs"
    size    = "32G"
  }
  
  // Network configuration
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }

  start = true
}