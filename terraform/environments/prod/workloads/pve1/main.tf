module "vm-management" {
  source = "../../../../modules/vm-clone-bgp"

  proxmox_host = var.proxmox_host
  domain       = var.domain
  gateway      = var.gateway
  template_id  = var.ubuntu24_template_id

  disksize    = "64"
  hostname    = "management"
  cores       = 2
  sockets     = 1
  memory      = 2048
  tags        = ["management", "vm", "proxmox"]
  description = "Management VM for Proxmox Node - hosts PXE"
  ipaddress   = "192.168.2.7/24" # ✅ Now just set the IP with CIDR

  # ✅ Use templatefile() to render the ${hostname} and ${ssh_keys} variables
  cloud_init_content = templatefile("${path.module}/cloud-init-management.yml", {
    hostname = "management"
    ssh_keys = data.github_ssh_keys.pofo14_ssh_keys.keys
  })
}
