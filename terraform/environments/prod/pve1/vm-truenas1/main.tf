module "truenas_vm" {
  source = "../../../../modules/vm-clone-bgp"

  hostname = var.hostname
  domain = var.domain
  proxmox_host = var.proxmox_host
  template_id = var.truenas_template_id
  cores = var.cores
  sockets = var.sockets
  memory = var.memory
  tags = var.tags
  description = var.description
  gateway = var.gateway
}