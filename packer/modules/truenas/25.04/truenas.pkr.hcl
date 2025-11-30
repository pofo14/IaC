# TrueNAS top-level build file
source "proxmox-iso" "truenas" {
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  # Do not wait for SSH, need to manually reboot and turn on
  communicator             = "none"

  vm_id                = var.vm_id
  vm_name              = "${var.environment}-TrueNAS-${var.truenas_version}-template"
  template_description = var.template_description

  qemu_agent = true
  memory     = var.memory
  cores      = var.cores
  sockets    = var.sockets
  cpu_type   = "host"

  scsi_controller = "virtio-scsi-single"

  disks {
    type           = "scsi"
    storage_pool   = var.disk_storage
    disk_size      = "${var.disk_size_gb}G"
    format         = "raw"
  }

  network_adapters {
    model  = "virtio"
    bridge = var.network_bridge
  }

  boot_iso {
    iso_file         = local.iso_file
    iso_storage_pool = var.iso_storage_pool
    unmount          = true
  }

  boot_wait        = var.boot_wait
  boot_key_interval = var.boot_key_interval
  boot_command = local.boot_command
}

locals {
  iso_file = "${var.iso_storage_pool}:iso/TrueNAS-SCALE-25.04.2.1.iso"

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
    "<wait240>",

    # Hit Enter to complete install
    "<enter><wait3>",

    # Select 3 for Reboot
    "3<wait3><enter>",

    # wait for reboot, 75 seconds
    "<wait240>",

    # At console menu, select option 9 (Shell)
    "${var.truenas_shell_option}<enter>",
    # Wait for shell prompt
    "<wait5>",

    # Enable SSH using midclt commands at console
    # Disable password authentication and root login for security
    "midclt call ssh.update '{\"passwordauth\": false, \"kerberosauth\": false}'<enter>",

    # Disable root login for security
    "midclt call ssh.update '{\"permitrootlogin\": \"disabled\"}'<enter>",
    "<wait3>",

    # Enable SSH service
    "midclt call service.update ssh '{\"enable\": true}'<enter>",
    "<wait3>",

    # Create SSH directory if it doesn't exist
    "mkdir -p /home/truenas_admin/.ssh<enter>",
    "<wait3>",

    # Fetch GitHub keys and append to authorized_keys (using jq if available, else grep fallback)
    "curl -s https://api.github.com/users/${var.github_user}/keys | (jq -r '.[].key' 2>/dev/null || grep -o '\"ssh-[^\"]*\"' | sed 's/\"//g') >> /home/truenas_admin/.ssh/authorized_keys<enter>",
    "<wait5>",  # Wait for curl to complete and write

    # Set proper permissions for security
    "chmod 600 /home/truenas_admin/.ssh/authorized_keys<enter>",
    "<wait1>",
    "chmod 700 /home/truenas_admin/.ssh<enter>",
    "<wait1>",
    "chown -R truenas_admin:truenas_admin /home/truenas_admin/.ssh<enter>",
    "<wait1>",

    # Start SSH service
    "midclt call service.start ssh<enter>",
    "<wait3>",

    # exit back to menu
    "exit<enter>",
    "<wait3>",

    # At console menu, select Shutdown (option 9 by default)
    #"${var.truenas_shutdown_option}<enter><wait3>",
    #"Installation complete, shutting down...<enter>",
  ]

}

build {
  sources = ["source.proxmox-iso.truenas"]
}
