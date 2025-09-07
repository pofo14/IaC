module "truenas1_vm" {
  source = "../../../../modules/vm-clone-bgp"

  hostname = var.hostname
  domain = var.domain
  proxmox_host = var.proxmox_host
  storage_pool = var.storage_pool
  template_id = var.truenas_template_id
  cores = var.cores
  sockets = var.sockets
  memory = var.memory
  tags = var.tags
  description = var.description
  gateway = var.gateway
  ssh_keys = data.github_ssh_keys.pofo14_ssh_keys.keys
  disksize = 100  # Increase to 100GB for TrueNAS storage
  use_cloud_init = false  # Disable cloud-init for TrueNAS
}