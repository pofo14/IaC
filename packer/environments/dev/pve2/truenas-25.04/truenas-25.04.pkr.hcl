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
  iso_file         = "local:iso/TrueNAS-SCALE-24.10.2.iso"
  unmount_iso      = true
  iso_storage_pool = "local"

  # System Settings
  os       = "l26"
  memory   = var.memory
  cores    = var.cores
  sockets  = 1
  cpu_type = "host"
  bios     = "ovmf"

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

  # HTTP Settings
  http_directory    = "${path.root}/http"
  http_bind_address = "0.0.0.0"
  http_port_min     = 8100
  http_port_max     = 8100

  # Boot configuration
  boot_wait = "45s"
  boot_command = [
    "1<enter><wait5>",
    "<spacebar><wait3><enter><wait5>",
    "y<wait5>",
    "1<wait2><enter><wait5>",
    "${var.truenas_root_password}<tab><wait5>",
    "${var.truenas_root_password}<wait5>",
    "<enter><wait3>",
    "<enter><wait3>",
    "<wait150>",
    "<enter><wait3>",
    "<wait10>",
    "3<wait2><enter><wait5>",
    "<wait150>",
    "7<wait3><enter><wait15>",
    "service update id_or_name=ssh enable=true<wait3><enter><wait7>",
    "service start service=ssh<wait3><enter><wait7>q<wait3>",
    "service ssh update password_login_groups=truenas_admin<wait5><enter><wait5>",
    "quit<enter><wait20>",
    "10<wait3><enter><wait3>image build<enter><wait5>"
  ]

  communicator = "none"
}

build {
  sources = ["source.proxmox-iso.truenas"]
}
