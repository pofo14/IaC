module "utils_vm" {
  source = "../../../../modules/vm-clone-bgp"

  hostname = var.hostname
  domain = var.domain
  proxmox_host = var.proxmox_host
  template_id = var.ubuntu24_template_id
  cores = var.cores
  sockets = var.sockets
  memory = var.memory  
  tags = var.tags
  description = var.description
  ipaddress = var.ipaddress
  gateway = var.gateway
  ssh_keys = data.github_ssh_keys.pofo14_ssh_keys.keys
}
