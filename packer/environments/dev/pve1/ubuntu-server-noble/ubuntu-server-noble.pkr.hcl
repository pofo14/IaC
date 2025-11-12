# Ubuntu Server Noble (24.04.x)
# ---
# Packer Template to create an Ubuntu Server (Noble 24.04.x) on Proxmox

locals {
  template_name = "ubuntu-server-noble-${var.environment}-${var.node_suffix}-template"
  vm_name = "ubuntu-server-noble-${var.environment}-${var.node_suffix}"
  vm_id = var.vm_id
}

# Resource Definiation for the VM Template
source "proxmox-iso" "ubuntu-server-noble" {

    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true

    # VM General Settings
    node = var.proxmox_node
    vm_id = local.vm_id
    vm_name = local.vm_name
    template_description = "Ubuntu Server Noble ${var.environment}/${var.node_suffix}"

    # VM OS Settings
    # (Option 1) Local ISO File
    #iso_file = "zfsdata01:iso/ubuntu-24.04.1-live-server-amd64.iso"
    boot_iso {
      #type = "zfsdata01"
      iso_file = "zfsdata01:iso/ubuntu-24.04.1-live-server-amd64.iso"
      unmount = true
    }

    # VM System Settings
    # qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "20G"
        format = "raw"
        storage_pool = "zfsdata01"
        #storage_pool_type = "zfs"
        type = "virtio"
    }

    # VM CPU Settings
    cores = var.cores

    # VM Memory Settings
    memory = var.memory

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    }

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "zfsdata01"

    # PACKER Boot Commands
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        #"autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "autoinstall ds=nocloud-net\\;s=http://192.168.2.236:{{ .HTTPPort }}/ ---<wait>",
        "<wait>",
        "<f10><wait>"
    ]

    boot                    = "c"
    boot_wait               = "15s"
    communicator            = "ssh"

    qemu_agent = true

    # PACKER Autoinstall Settings
    http_directory          = "http"
    # (Optional) Bind IP Address and Port
    #http_bind_address       = "0.0.0.0"
    #http_bind_address       = "172.24.22.178"
    #http_interface         = "vEthernet (WSL (Hyper-V firewall))"
    http_port_min           = 8336
    http_port_max           = 8336

    ssh_username            = "pofo14"

    # (Option 1) Add your Password here
    # ssh_password        = "your-password"
    # - or -
    # (Option 2) Add your Private SSH KEY file here
    ssh_private_key_file    = "~/.ssh/id_ed25519"

    # Raise the timeout, when installation takes longer
    ssh_timeout             = "30m"
    ssh_handshake_attempts = "100"
    ssh_pty                 = true
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-noble"
    sources = ["source.proxmox-iso.ubuntu-server-noble"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync",
            "sudo systemctl start qemu-guest-agent",
            "sudo systemctl enable qemu-guest-agent"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    # Add additional provisioning scripts here
    # ...
}


# TODO: Need to document dev machine setup, and this requires packer plugins install github.com/hashicorp/proxmox
# TODO: setup http netsh interface portproxy add v4tov4 listenport=8336 listenaddress=0.0.0.0 connectport=8336 connectaddress=(wsl hostname -I)
# TODO: netsh interface portproxy delete v4tov4 listenport=8336 listenaddress=0.0.0.0
