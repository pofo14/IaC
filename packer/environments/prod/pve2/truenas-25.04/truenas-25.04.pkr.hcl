locals {
  template_name = "truenas-${var.environment}-${var.node_suffix}-template"
  vm_name       = "truenas-${var.environment}-${var.node_suffix}"
}

source "proxmox-iso" "truenas" {
  # Proxmox Connection
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  # VM Settings
  vm_id                = var.vm_id
  vm_name              = local.vm_name
  template_description = "TrueNAS SCALE 25.04 template for ${var.environment}"

  # ISO Settings
  boot_iso {
    type             = "scsi"
    iso_file         = "local:iso/TrueNAS-SCALE-24.10.2.iso"
    iso_storage_pool = "local"
    unmount          = true
  }

  # System Settings
  os       = "l26"
  memory   = var.memory
  cores    = var.cores
  sockets  = 1
  cpu_type = "host"
  bios     = "ovmf"

  # EFI disk (required for UEFI boot)
  efi_config {
    efi_storage_pool  = var.disk_storage
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  # Disk Settings
  scsi_controller = "virtio-scsi-single"
  disks {
    disk_size    = "32G"
    storage_pool = var.disk_storage
    type         = "scsi"
  }

  # Network Settings
  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # Boot configuration
  boot_wait = "10s"
  boot_command = [
    # Wait for installer to start
    "<wait30>",
    # Select Install/Upgrade (option 1)
    "1<enter>",
    # Wait for disk selection
    "<wait10>",
    # Select first disk (option 1)
    "1<enter>",
    # Confirm installation
    "<enter>",
    # Wait for installation to complete (about 5-6 minutes)
    "<wait120><wait120><wait120>",
    # System reboots automatically, wait for console menu
    "<wait60><wait30>",
    # At console menu, select option 9 (Shell)
    "9<enter>",
    # Wait for shell prompt
    "<wait5>",
    # Enable SSH using midclt commands at console
    "midclt call ssh.update '{\"tcpport\": 22, \"rootlogin\": true}'<enter>",
    "<wait3>",
    "midclt call service.start ssh<enter>",
    "<wait3>",
    "midclt call service.update ssh '{\"enable\": true}'<enter>",
    "<wait3>",
    # Exit shell back to menu
    "exit<enter>",
    # Wait for SSH to be ready
    "<wait10>"
  ]

  # SSH Settings - NOW Packer can connect
  ssh_username           = "root"
  ssh_password           = var.truenas_root_password
  ssh_timeout            = "10m"
  ssh_handshake_attempts = 50
  ssh_pty                = true

  # Template Settings
  template_name = local.template_name
}

build {
  sources = ["source.proxmox-iso.truenas"]

  # Verify SSH is working and system is ready
  provisioner "shell" {
    inline = [
      "echo 'Connected via SSH successfully!'",
      "midclt call system.ready",
      "midclt call system.info | grep version"
    ]
  }

  # Final configuration
  provisioner "shell" {
    inline = [
      "echo 'TrueNAS SCALE template created successfully'",
      "echo 'SSH is enabled and will persist after template conversion'"
    ]
  }
}
