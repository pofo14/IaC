data "http" "github_keys" {
  url = "https://api.github.com/users/${var.github_username}/keys"
}

locals {
  ssh_keys = length(var.ssh_authorized_keys) > 0 ? var.ssh_authorized_keys : (
    var.github_username != "" ?
      [for key in jsondecode(data.http.github_keys.body) : key.key] :
      []
  )

  user_data_content = templatefile("${path.cwd}/modules/ubuntu/24.04/cloud-init/user-data.tpl", {
    username      = var.ssh_username
    password_hash = var.default_user_password_hash
    ssh_keys      = local.ssh_keys
  })

  iso_file = "${var.iso_storage_pool}:iso/ubuntu-24.04.3-live-server-amd64.iso"
}

source "proxmox-iso" "ubuntu" {
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  vm_id                = var.vm_id
  vm_name              = "${var.environment}-ubuntu-server-${var.ubuntu_version}-template"
  template_description = var.template_description

  qemu_agent       = true
  memory           = var.memory
  cores            = var.cores
  sockets          = 1
  cpu_type         = var.cpu_type
  scsi_controller  = "virtio-scsi-single"

  boot_iso {
    iso_file         = local.iso_file
    iso_storage_pool = var.iso_storage_pool
    unmount          = true
  }

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

  cloud_init              = false

  additional_iso_files {
    type             = "ide"
    iso_storage_pool = var.iso_storage_pool

    cd_content = {
      "meta-data" = file("${path.cwd}/modules/ubuntu/24.04/cloud-init/meta-data")
      #"user-data" = file("${path.cwd}/modules/ubuntu/24.04/cloud-init/user-data")
      "user-data" = local.user_data_content
    }
    cd_label = "cidata"
    unmount  = true
  }

  boot = "order=scsi0;ide2"
  boot_wait = "10s"
  boot_command = [

    "c<wait5>",

    ## WORKING LOCAL COMMAND - Loads User Data ###
    "linux /casper/vmlinuz --- autoinstall ds=nocloud;s=/cdrom/cidata/",

    ## WORKING HTTP COMMAND - Loads User Data ###
    #"linux /casper/vmlinuz --- autoinstall ds=nocloud;s=http://192.168.2.119:8080/ ---<enter><wait10>",
    "<enter><wait10>",
    "initrd /casper/initrd<enter><wait10>",
    "boot<enter><wait5>"

  ]

  communicator         = "ssh"
  ssh_username         = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout          = "30m"
  ssh_pty              = true
}

build {

  # provisioner "shell-local" {
  #   inline = [
  #     "mkdir -p ${path.cwd}/modules/ubuntu/24.04/cloud-init",
  #     "cat > ${path.cwd}/modules/ubuntu/24.04/cloud-init/user-data.generated.cat <<'USERDATA_EOF'\n${local.user_data_content}\nUSERDATA_EOF",
  #     "echo 'WROTE: modules/ubuntu/24.04/cloud-init/user-data.generated'",
  #     "wc -c ${path.cwd}/modules/ubuntu/24.04/cloud-init/user-data.generated || true"
  #   ]
  # }

  sources = ["source.proxmox-iso.ubuntu"]

  # provisioner "shell-local" {
  #   inline = [
  #     "mkdir -p ${path.cwd}/modules/ubuntu/24.04/http/",
  #     "echo '${local.user_data_content}' > ${path.cwd}/modules/ubuntu/24.04/http/user-data"
  #   ]
  # }

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm -f /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }

  provisioner "shell" {
    inline = [
      # enable & start qemu-guest-agent but don't let a non-fatal enable message fail the build
      "sudo systemctl enable --now qemu-guest-agent || true",
      "sudo systemctl start qemu-guest-agent || true",
      "sudo systemctl status qemu-guest-agent --no-pager || true"
    ]
  }
}
