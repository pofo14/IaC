locals {
  template_name = "${var.template_name_prefix}-${var.environment}-${var.node_suffix}-template"
  vm_name       = "${var.template_name_prefix}-${var.environment}-${var.node_suffix}"
  #iso_file_full    = "${var.storage_pool_zfs}:${var.storage_pool_iso}/${var.iso_filename}"
  iso_file_full    = "${var.storage_pool_iso}:iso/${var.iso_filename}"
}

source "proxmox-iso" "truenas" {
  # Proxmox Connection
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node
  communicator             = "none"

  # VM Settings
  vm_id                = var.vm_id
  vm_name              = local.vm_name
  template_description = "TrueNAS SCALE ${var.truenas_version} template for ${var.environment}"

  # ISO Settings (use boot_iso block like OPNsense)
  boot_iso {
    iso_storage_pool = var.storage_pool_iso
    iso_file = local.iso_file_full
    unmount          = true
  }

  # System Settings
  qemu_agent = false
  memory     = var.memory
  cores      = var.cores
  sockets    = 1
  cpu_type   = "host"

  scsi_controller = "virtio-scsi-single"

  # Disk Settings
  disks {
      type         = "scsi"
      storage_pool = "zfs01" #var.disk_storage
      #storage_pool_type = "zfspool"
      disk_size    = "32G" #var.disk_size_mb
      format       = "raw"
  }

  # Network Settings
  # network_adapters {
  #   model  = "virtio"
  #   bridge = var.network_bridge
  # }

  # Boot configuration
  boot_wait = "10s"

  # Increase boot command timeout
  boot_key_interval = "10ms" # Speed up typing

  boot_command = [
    # Wait for installer to start
    "<wait30>",
    # Select Install/Upgrade (option 1)
    "1<enter>",
    # Wait for disk selection
    "<wait10>",
    # Select first disk (option 1)
    "<spacebar><enter><wait3>",
    # Confirm installation
    "<enter><wait3>",
    # Configure Administrative user (truenas_admin)
    "1<enter><wait3>",
    # Enter Password, tab
    "${var.truenas_root_password}<tab>",
    # Re-Enter Password, OK (press o)
    "${var.truenas_root_password}<tab><enter><wait3>",

    # Yes to EFI Boot
    "<enter>",

    # Wait for installation to complete (about 2 minutes)
    "<wait150>",

    # Hit Enter to complete install
    "<enter><wait3>",

    # Select 3 for Reboot
    "3<wait3><enter>",

    # Wait for system reboots, wait for console menu
    "<wait110>",
    # At console menu, select Shutdown (option 9 by default)
    "${var.truenas_shutdown_option}<enter>",
    # Give it a moment to power off
    "<wait30>"
  ]

  # Template Settings
  template_name = local.template_name
}

build {
  sources = ["source.proxmox-iso.truenas"]
}
