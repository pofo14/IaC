resource "proxmox_virtual_environment_vm" "vm_clone" {
  name      = var.hostname
  node_name = var.proxmox_host
  tags      = length(var.tags) > 0 ? var.tags : ["default-tag"]

  machine     = var.machine
  bios        = var.bios
  description = var.description 

  clone {
    vm_id = var.template_id
    datastore_id = var.storage_pool
    full = true
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

  dynamic "efi_disk" {
    for_each = var.efidisk_enabled ? [1] : []
    content {
      datastore_id      = var.efidisk_datastore
      file_format       = var.efidisk_file_format
      type              = var.efidisk_type
      pre_enrolled_keys = var.efidisk_pre_enrolled_keys
    }
  }

  # Add PCI passthrough devices
dynamic "hostpci" {
  for_each = var.pci_mappings
  content {
    device  = "hostpci${hostpci.key}"  # This creates hostpci0, hostpci1, etc.
    mapping = hostpci.value            # This uses the mapping name like "hba_1"
    pcie    = true
    rombar  = true
  }
}

  disk {
    #datastore_id = var.storage_pool
    #interface    = "virtio0"
    #iothread     = true
    #discard      = "on"
    #size         = var.disksize

    aio               = "io_uring"
    backup            = true
    cache             = "none"
    datastore_id      = var.storage_pool
    discard           = "on"
    file_format       = "raw"  # Explicitly set raw format for ZFS
    interface         = "virtio0"
    iothread          = true
    replicate         = true
    size              = var.disksize
    ssd               = false
  }

  # Set scsi hardware controller if provided
  scsi_hardware = var.scsi_hardware

  # Only include cloud-init initialization if use_cloud_init is true
  dynamic "initialization" {
    for_each = var.use_cloud_init ? [1] : []
    content {
      datastore_id = "snippets"
      dynamic "ip_config" {
        for_each = var.ipaddress != "dhcp" && var.ipaddress != "" && var.ipaddress != "ip=dhcp" ? [1] : []
        content {
          ipv4 {
            address = var.ipaddress
            gateway = var.gateway
          }
        }
      }
      user_data_file_id = var.use_cloud_init ? proxmox_virtual_environment_file.user_data_cloud_config[0].id : null
    }
  }

  network_device {
    bridge = "vmbr0"
  }

}

# Only create cloud-init file if use_cloud_init is true
resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  count = var.use_cloud_init ? 1 : 0
  
  content_type = "snippets"
  datastore_id = "snippets"
  node_name    = var.proxmox_host
  timeout_upload = 1800
  
  source_raw {
    file_name = "${var.hostname}.cloud-config.yaml"
    data = <<-EOT
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
%{ for key in var.ssh_keys ~}
           - ${key}
%{ endfor ~}

    write_files:
      - path: /etc/netplan/99-custom.yaml
        content: |
          network:
            version: 2
            ethernets:
              eth0:  
                %{if var.ipaddress == "dhcp" || var.ipaddress == "" || var.ipaddress == "ip=dhcp" }
                dhcp4: true
                dhcp4-overrides:
                  send-hostname: true
                  use-hostname: true
                  hostname: ${var.hostname}
                dhcp-identifier: mac
                %{else}
                dhcp4: false
                addresses:
                  - ${var.ipaddress}
                gateway4: ${var.gateway}
                nameservers:
                  addresses: [192.168.2.2]
                routes:
                  - to: default
                    via: ${var.gateway}
                %{endif}
             
      - path: /etc/hosts
        content: |
          127.0.0.1 localhost
          127.0.1.1 ${var.hostname}.${var.domain} ${var.hostname}

    runcmd:
      - netplan apply
      - hostnamectl set-hostname ${var.hostname}.${var.domain}
      - systemctl restart systemd-hostnamed
    EOT
  }

}
