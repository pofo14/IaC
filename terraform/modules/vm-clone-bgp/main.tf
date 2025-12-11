resource "proxmox_virtual_environment_vm" "vm_clone" {

  name      = var.hostname
  node_name = var.proxmox_host
  tags      = length(var.tags) > 0 ? var.tags : ["default-tag"]

  machine     = var.machine
  bios        = var.bios
  description = var.description

  clone {
    vm_id        = var.template_id
    datastore_id = var.storage_pool
    full         = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores   = var.cores
    sockets = var.sockets
    type    = var.cpu_type
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
      device  = "hostpci${hostpci.key}"
      mapping = hostpci.value
      pcie    = true
      rombar  = true
    }
  }

  # # Override the template/rootfs disksize from template, if different
  disk {
    backup       = true
    datastore_id = var.storage_pool
    discard      = "on"
    interface    = "scsi0" # ← Same interface as template
    iothread     = true
    replicate    = true
    size         = var.disksize # ← This will RESIZE the template's disk
    ssd          = true
  }

  # Add an additional disk beyond the template's disk if requested
  dynamic "disk" {
    for_each = var.add_extra_disk ? var.extra_disks : []
    content {
      aio          = "io_uring"
      backup       = true
      cache        = "none"
      datastore_id = var.storage_pool
      discard      = "on"
      file_format  = "raw"
      interface    = "scsi${disk.key + 1}" # ← scsi1, scsi2, scsi3, etc. (scsi0 is the root disk)
      iothread     = true
      replicate    = true
      size         = disk.value.size
      ssd          = lookup(disk.value, "ssd", true)
    }
  }

  scsi_hardware = var.scsi_hardware

  # Only include initialization if cloud-init content is provided
  dynamic "initialization" {
    for_each = var.cloud_init_content != "" ? [1] : []
    content {
      datastore_id = var.storage_pool_snippets

      # Set static IP if not using DHCP
      dynamic "ip_config" {
        for_each = var.ipaddress != "dhcp" && var.ipaddress != "" ? [1] : []
        content {
          ipv4 {
            address = var.ipaddress
            gateway = var.gateway
          }
        }
      }

      # Use DHCP if no static IP specified
      dynamic "ip_config" {
        for_each = var.ipaddress == "dhcp" || var.ipaddress == "" ? [1] : []
        content {
          ipv4 {
            address = "dhcp"
          }
        }
      }

      user_data_file_id = var.cloud_init_content != "" ? proxmox_virtual_environment_file.user_data_cloud_config[0].id : null
    }
  }

  network_device {
    bridge = "vmbr0"
  }

  depends_on = [proxmox_virtual_environment_file.user_data_cloud_config]
}

# Only create cloud-init file if content is provided
resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  count = var.cloud_init_content != "" ? 1 : 0

  content_type   = "snippets"
  datastore_id   = var.storage_pool_snippets
  node_name      = var.proxmox_host
  timeout_upload = 1800

  source_raw {
    file_name = "${var.hostname}.cloud-config.yaml"
    data      = var.cloud_init_content
  }
}
