module "nextcloud_vm" {
  source = "../../../modules/vm-clone"
  providers = {
    proxmox = proxmox
  }

  vm_name = var.vm_name
  proxmox_host = var.proxmox_host
  template_name = var.ubuntu24_template_name
  cores = 2
  sockets = 1
  memory = 4096  # 4GB
  ssh_keys = var.ssh_key
  ciuser = var.ciuser
  ipaddress = var.ipaddress
  #cipassword = var.cipassword
}
