# ============================================================
# CONFIG.XML IS STORED IN ./conf/config.xml
# Packer makes an ISO and attaches it as an extra CD
# ============================================================
source "proxmox-iso" "opnsense" {
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  vm_id   = var.vm_id
  vm_name = "${var.environment}-opnsense-${var.opnsense_version}"
  template_description = "Automated OPNsense ${var.opnsense_version}"

  qemu_agent = false
  memory     = 4096
  cores      = 2
  cpu_type   = "x86-64-v2-AES"
  scsi_controller = "virtio-scsi-single"

  serials = ["socket"]

  boot_iso {
    iso_file         = var.iso_file
    iso_storage_pool = var.iso_storage_pool
    unmount          = true
    index     = 2
  }

  # Main OPNsense installer ISO already on Proxmox
  # additional_iso_files {
  #   iso_file         = "${var.iso_storage_pool}:iso/OPNsense-${var.opnsense_version}-dvd-amd64.iso"
  #   type             = "ide"
  #   unmount          = true
  # }

  # Our config.xml packaged into a CD
  additional_iso_files {
    type             = "ide"
    iso_storage_pool = var.iso_storage_pool
    cd_files         = ["modules/opnsense/25.7/conf"]
    cd_label         = "CONFIG"
    unmount          = true
    index     = 1
  }

  disks {
    type         = "scsi"
    storage_pool = var.disk_storage
    disk_size    = "32G"
    format       = "raw"
  }

  network_adapters {
    model  = "virtio"
    bridge = var.network_bridge
  }

  boot = "order=scsi0;ide2"

  boot_wait = "120s"
  communicator = "none"
  boot_command = [
    # ------------------------
    # 1. BOOT THE INSTALLER
    # ------------------------
    "installer<enter><wait3>",

    "opnsense<enter><wait3>",

    # Keyboard layout OK
    "<enter><wait10>",

    # ZFS filesystem
    "<enter><wait10>",

    # Pool layout OK (stripe)
    "<enter><wait5>",

    # Pick disk (first disk: ada0)
    "<spacebar><enter><wait3>",
    "y",    # Confirm erase + install
    "<wait300>",    # INSTALL TIME (adjust if needed)

    # Complete & reboot
    "c<enter><wait10>",
    "r<enter>",
    "<wait150>",    # Reboot TIME (adjust if needed)

    # At bootloader, choose shell #
    "root<enter><wait3>",
    "opnsense<enter><wait3>",
    "8<enter><wait4>",

    # Mount config ISO and copy config.xml #
    "mkdir -p /tmp/config<enter><wait3>",
    "mount_cd9660 /dev/cd0 /tmp/config<enter><wait3>",
    "cp /tmp/config/conf/config.xml /conf/config.xml<enter><wait5>",
    "sync<enter><wait2>",

    # Final reboot, apply new config.xml #
    "reboot<enter>",
    "<wait150>",

  ]
}

build {
  sources = ["source.proxmox-iso.opnsense"]
}
