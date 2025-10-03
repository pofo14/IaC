# TrueNAS VM deployment with PCI passthrough for storage controllers

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.70.1"
    }
  }
}

provider "proxmox" {
  # Configuration from environment variables or terraform.tfvars
}

# Variables
variable "pci_ids" {
  description = "List of PCI IDs to pass through to TrueNAS"
  type = list(string)
  default = [
    "82:00.0",  # LSI SAS controller - update with your actual PCI ID
    "00:1f.2"   # SATA controller - update with your actual PCI ID
  ]
}

variable "vm_id" {
  description = "VM ID for TrueNAS"
  type = number
  default = 101
}

variable "hostname" {
  description = "Hostname for TrueNAS"
  type = string
  default = "truenas1"
}

variable "domain" {
  description = "Domain for TrueNAS"
  type = string
  default = "flopo.retropetro.net"
}

# Create the VM from template
module "truenas_vm" {
  source = "../../../../modules/vm-clone-bgp"
  
  hostname = var.hostname
  proxmox_host = "pve1"
  template_id = 9000  # ID of the TrueNAS template
  description = "TrueNAS Core Server"
  domain = var.domain
  
  memory = 16384  # 16 GB
  cores = 4
  sockets = 1
  cpu_type = "host"
  
  storage_pool = "zfsdata01"
  disksize = "20G"
  
  ipaddress = "192.168.2.113/24"
  gateway = "192.168.2.1"
  
  # Cloud-init configuration
  use_cloud_init = false
  ssh_keys = []
}

# Apply PCI passthrough for storage controllers
module "pci_passthrough" {
  source = "../../../../modules/pve-pci-passthrough"
  
  vm_id = var.vm_id
  node_name = "pve1"
  pci_ids = var.pci_ids
  
  depends_on = [module.truenas_vm]
}

output "truenas_vm" {
  value = {
    id = module.truenas_vm.vm_id
    hostname = var.hostname
    fqdn = "${var.hostname}.${var.domain}"
    ip = "192.168.2.113"
    pci_ids = module.pci_passthrough.pci_ids
  }
}
