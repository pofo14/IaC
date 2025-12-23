# Production Infrastructure VMs on PVE1
# Management VLAN (10.10.10.0/24) Core Services

locals {
  # VM-specific configurations (the things that SHOULD be unique)
  vms = {
    pihole1 = {
      name        = "pihole01"
      vmid        = 1041
      ip_address  = "10.10.10.41"
      cores       = 2
      memory      = 2048
      disk_size   = "32G"
      service_tag = "pihole"
      vlan_tag    = 10
    }
    pihole2 = {
      name        = "pihole02"
      vmid        = 1042
      ip_address  = "10.10.10.42"
      cores       = 2
      memory      = 2048
      disk_size   = "32G"
      service_tag = "pihole"
      vlan_tag    = 10
    }
    stepca = {
      name        = "stepca"
      vmid        = 1030
      ip_address  = "10.10.10.30"
      cores       = 2
      memory      = 4096
      disk_size   = "32G"
      service_tag = "stepca"
      vlan_tag    = 10
    }
    pxe = {
      name        = "pxe"
      vmid        = 1050
      ip_address  = "10.10.10.50"
      cores       = 2
      memory      = 4096
      disk_size   = "32G"
      service_tag = "pxe"
      vlan_tag    = 10
    }
  }
}

# Pi-hole DNS Server #1
module "pihole1" {
  source = "../../../../modules/vm-clone-bgp"

  hostname     = local.vms.pihole1.name
  domain       = "flopo.retropetro.net"
  proxmox_host = var.target_node
  template_id  = var.ubuntu_template_id

  cores  = local.vms.pihole1.cores
  memory = local.vms.pihole1.memory

  disksize     = replace(local.vms.pihole1.disk_size, "G", "")
  storage_pool = var.default_storage

  ipaddress = "${local.vms.pihole1.ip_address}/${var.management_vlan.subnet_prefix}"
  gateway   = var.management_vlan.gateway
  vlan_tag  = local.vms.pihole1.vlan_tag

  cloud_init_content = templatefile("${path.module}/cloud-init-pihole.yml", {
    hostname = local.vms.pihole1.name
    ssh_keys = var.ssh_authorized_keys
  })

  tags = ["terraform", "pihole", "dns"]
}

# Pi-hole DNS Server #2
module "pihole2" {
  source = "../../../../modules/vm-clone-bgp"

  hostname     = local.vms.pihole2.name
  domain       = "flopo.retropetro.net"
  proxmox_host = var.target_node
  template_id  = var.ubuntu_template_id

  cores  = local.vms.pihole2.cores
  memory = local.vms.pihole2.memory

  disksize     = replace(local.vms.pihole2.disk_size, "G", "")
  storage_pool = var.default_storage

  ipaddress = "${local.vms.pihole2.ip_address}/${var.management_vlan.subnet_prefix}"
  gateway   = var.management_vlan.gateway
  vlan_tag  = local.vms.pihole2.vlan_tag

  cloud_init_content = templatefile("${path.module}/cloud-init-pihole.yml", {
    hostname = local.vms.pihole2.name
    ssh_keys = var.ssh_authorized_keys
  })

  tags = ["terraform", "pihole", "dns"]
}

# StepCA Certificate Authority
module "stepca_prod" {
  source = "../../../../modules/vm-clone-bgp"

  hostname     = local.vms.stepca.name
  domain       = "flopo.retropetro.net"
  proxmox_host = var.target_node
  template_id  = var.ubuntu_template_id

  cores  = local.vms.stepca.cores
  memory = local.vms.stepca.memory

  disksize     = replace(local.vms.stepca.disk_size, "G", "")
  storage_pool = var.default_storage

  ipaddress = "${local.vms.stepca.ip_address}/${var.management_vlan.subnet_prefix}"
  gateway   = var.management_vlan.gateway
  vlan_tag  = local.vms.stepca.vlan_tag

  cloud_init_content = templatefile("${path.module}/cloud-init-stepca.yml", {
    hostname = local.vms.stepca.name
    ssh_keys = var.ssh_authorized_keys
  })

  tags = ["terraform", "stepca", "pki"]
}

# PXE / Netboot Container Host
module "pxe_prod" {
  source = "../../../../modules/vm-clone-bgp"

  hostname     = local.vms.pxe.name
  domain       = "flopo.retropetro.net"
  proxmox_host = var.target_node
  template_id  = var.ubuntu_template_id

  cores  = local.vms.pxe.cores
  memory = local.vms.pxe.memory

  disksize     = replace(local.vms.pxe.disk_size, "G", "")
  storage_pool = var.default_storage

  ipaddress = "${local.vms.pxe.ip_address}/${var.management_vlan.subnet_prefix}"
  gateway   = var.management_vlan.gateway
  vlan_tag  = local.vms.pxe.vlan_tag

  cloud_init_content = templatefile("${path.module}/cloud-init-pxe.yml", {
    hostname = local.vms.pxe.name
    ssh_keys = var.ssh_authorized_keys
  })

  tags = ["terraform", "pxe", "netboot"]
}
