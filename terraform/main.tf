terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.11"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.proxmox_api_var
  pm_api_token_id = var.proxmox_api_token_var
  pm_api_token_secret = var.proxmox_api_token_secret_var
  pm_tls_insecure = true

  # pm_debug = true
  # pm_log_levels = {
  #   _default    = "debug"
  #   _capturelog = "tf-debug.log"
  # }   
}

resource "proxmox_vm_qemu" "vm_factory" {
  name = "${var.env}-${var.vm_name}"
  target_node = var.proxmox_host
  clone = var.template_name

  # basic VM settings here. agent refers to guest agent
  agent = 1
  os_type = "cloud-init"
  cores = var.vm_cores
  sockets = 1
  cpu = "host"
  memory = var.vm_memory
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot = 0
    size = var.vm_disk_size
    type = "scsi"
    storage = var.disk_storage
    iothread = 1
  }
  
  network {
    model = "virtio"
    bridge = var.network_bride
  }

  lifecycle {
    ignore_changes = [
        network,
    ]
  }

  #set to get IP from DHCP
  ipconfig0= "ip=dhcp" 
  
  # SSH key for the detault user
  sshkeys = var.ssh_keys
}
