terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.70.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm_clone" {
  name      = var.hostname
  node_name = var.proxmox_host
  tags      = length(var.tags) > 0 ? var.tags : ["default-tag"]

  machine     = "q35"
  //bios        = "ovmf"
  description = var.description 

  clone {
    vm_id = var.template_id
    datastore_id = var.storage_pool
  }

  agent {
    enabled = true
  }

  cpu {
    cores = var.cores
    sockets = var.sockets
    type   = var.cpu_type 
  }

  memory {
    dedicated = var.memory
    floating  = var.memory
  }

  # efi_disk {
  #   datastore_id = "zfsdata01"
  #   file_format  = "raw"
  #   type         = "4m"
  # }


  disk {
    datastore_id = var.storage_pool
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disksize
  }

  initialization {
    datastore_id = "zfsdata01"
    ip_config {
      ipv4 {
        address = var.ipaddress
        gateway = var.gateway
      }
    }
    # TODO: Figure out how to pull in the ssh keys from the data source from GitHub
    # user_account {
    #   username = "pofo14"
    #   keys =  [
    #         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHzt5Uq1pY/zXZp30wjueijLzigpuAJ2p1Bew5AOMQ7y pofo14@Joes-MacBook-Pro.local",
    #         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFw3M5B7y0icwQpUO2NvYEqg1qckmd1j01YpAxhm+HM pofo14@pc-ken",
    #         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILrhhjNH6tibJ1wVoZojtuUIcRamnOdQBwwS2RVGmDfN ansible user - windows pc"
    #   ]
    #   //keys = var.ssh_keys

    # }
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "zfsdata01"
  node_name    = "proxmox"

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: ${var.hostname}
    fqdn: ${var.hostname}.${var.domain}
    preserve_hostname: true
    manage_etc_hosts: true
    prefer_fqdn_over_hostname: true    
    users:
      - name: pofo14
        groups: [adm, sudo]
        lock-passwd: false
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        # passwd: 
        # - or -
        ssh_authorized_keys:
           - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHzt5Uq1pY/zXZp30wjueijLzigpuAJ2p1Bew5AOMQ7y pofo14@Joes-MacBook-Pro.local
           - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFw3M5B7y0icwQpUO2NvYEqg1qckmd1j01YpAxhm+HM pofo14@pc-ken
           - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILrhhjNH6tibJ1wVoZojtuUIcRamnOdQBwwS2RVGmDfN ansible user - windows pc

    write_files:
      - path: /etc/netplan/99-custom.yaml
        content: |
          network:
            version: 2
            ethernets:
              eth0:  
                %{if var.ipaddress != "" }
                dhcp4: false
                addresses:
                  - ${var.ipaddress}
                gateway4: ${var.gateway}
                nameservers:
                  addresses: [192.168.2.2]
                routes:
                  - to: default
                    via: ${var.gateway}                
                %{else}
                dhcp4: true
                dhcp4-overrides:
                  send-hostname: true
                  use-hostname: true
                  hostname: ${var.hostname}
                dhcp-identifier: mac
                %{endif}
             
      - path: /etc/hosts
        content: |
          127.0.0.1 localhost
          127.0.1.1 ${var.hostname}.${var.domain} ${var.hostname}

    runcmd:
      - netplan apply
      - hostnamectl set-hostname ${var.hostname}.${var.domain}
      - systemctl restart systemd-hostnamed

    EOF

    file_name = "${var.hostname}.cloud-config.yaml"
  }

}
