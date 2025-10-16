module "vm-management" {
  source = "../../../../modules/vm-clone-bgp"

  # Use environment defaults
  proxmox_host         = "proxmox" # var.proxmox_host
  domain               = var.domain
  gateway              = var.gateway
  template_id          = 402

  hostname = "test-management"
  cores = 2
  sockets = 1
  memory = 2048
  tags = ["management", "vm", "proxmox"]
  description = "Management VM for Proxmox Node - hosts PXE"
  ipaddress = "192.168.2.7"
  ssh_keys = data.github_ssh_keys.pofo14_ssh_keys.keys
}
