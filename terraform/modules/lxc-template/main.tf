terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.70.1"
    }
  }
}

resource "proxmox_virtual_environment_container" "container" {
  description = "Managed by Terraform"
  node_name = var.node_name


  initialization {
    hostname = var.hostname

    dns {
      domain = var.dns_domain
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = var.ip_address
      }
    }

    user_account {
      keys = [
        var.ssh_keys
      ]
      password = var.user_password
    }
  }

  memory {
    dedicated = var.memory
  }

  network_interface {
    name = "eth0"
  }

  operating_system {
    # You can use a volume ID, as obtained from a "pvesm list <storage>"
    # i.e. local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst
    template_file_id = var.os_template_file
    type             = var.ostype
  }

  # CPU and memory
  cpu {
    architecture = var.cpu_architecture
    cores   = var.cpu_cores
  }

  disk {
    datastore_id = var.storage_pool
    size         = var.rootfs_size
  }

  dynamic "mount_point" {
    for_each = var.mount_points
    content {
      volume = mount_point.value.storage_pool
      size   = mount_point.value.disk_size
      path   = mount_point.value.path
    }
  }

  startup {
    order      = var.startup_order
    up_delay   = var.up_delay
    down_delay = var.down_delay
  }

  pool_id = var.pool_id
  unprivileged = var.unprivileged

  tags      = length(var.tags) > 0 ? var.tags : ["default-tag"]

}