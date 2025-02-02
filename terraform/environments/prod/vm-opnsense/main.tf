module "nextcloud_vm" {
  source = "../../../modules/vm-iso"
  providers = {
    proxmox = proxmox
  }

  vm_name = var.vm_name
  proxmox_host = var.proxmox_host
  template_name = var.ubuntu24_template_name
  cores = var.cores
  sockets = var.sockets
  memory = var.memory
  ssh_keys = var.ssh_key
  ciuser = var.ciuser
  ipaddress = var.ipaddress
}
