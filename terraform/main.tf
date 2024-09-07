terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.11"
    }
  }
}

provider "proxmox" {
  # url is the hostname (FQDN if you have one) for the proxmox host you'd like to connect to to issue the commands. my proxmox host is 'prox-1u'. Add /api2/json at the end for the API
  pm_api_url = var.proxmox_api_var

  # api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = var.proxmox_api_token_var

  # this is the full secret wrapped in quotes. don't worry, I've already deleted this from my proxmox cluster by the time you read this post
  pm_api_token_secret = var.proxmox_api_token_secret_var

  # leave tls_insecure set to true unless you have your proxmox SSL certificate situation fully sorted out (if you do, you will know)
  pm_tls_insecure = true

  pm_debug = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = "tf-debug.log"
  }   
}

# output IP Address
output "vm_ip" {
  value = proxmox_vm_qemu.vm_factory.*.default_ipv4_address
}

# resource is formatted to be "[type]" "[entity_name]" so in this case
# we are looking to create a proxmox_vm_qemu entity named test_server
resource "proxmox_vm_qemu" "vm_factory" {
  name = "${var.env}-${var.vm_type}-${var.vm_name}"
  #name = var.server_hostmane
  target_node = var.proxmox_host
  clone = var.template_name

  # basic VM settings here. agent refers to guest agent
  agent = 1
  os_type = "ubuntu"
  cores = 3
  sockets = 1
  cpu = "host"
  memory = 4096
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  ci_wait = 30

  disk {
    slot = 0
    # set disk size here. leave it small for testing because expanding the disk takes time.
    size = "10G"
    type = "scsi"
    storage = "local-lvm"
    iothread = 0
  }
  
  # if you want two NICs, just copy this whole network section and duplicate it
  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
        network,
    ]
  }

  #set to get IP from DHCP
  ipconfig0= "ip=dhcp" 
  
  ciuser = var.ciuser
  # sshkeys set using variables. the variable contains the text of the key.
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF

}

resource "null_resource" "set-hostname" {
  connection {
    type = "ssh"
    user = "${var.ciuser}"
    host = proxmox_vm_qemu.vm_factory.*.default_ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${var.env}-${var.vm_type}-${var.vm_name}",
      "echo '127.0.0.1 ${var.env}-${var.vm_type}-${var.vm_name}' | sudo tee -a /etc/hosts",
      "sudo reboot"
    ]
  }
}
