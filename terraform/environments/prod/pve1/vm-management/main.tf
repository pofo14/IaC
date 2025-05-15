module "management_vm" {
  source = "../../../../modules/vm-iso-bgp"

  hostname = var.hostname
  domain = var.domain
  proxmox_host = var.proxmox_host
  cores = var.cores
  sockets = var.sockets
  memory = var.memory  
  tags = var.tags
  description = var.description
  gateway = var.gateway
}
