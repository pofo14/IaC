module "mealie_lxc" {
  source = "../../../modules/lxc-clone"
  providers = {
    proxmox = proxmox
  }

  hostname = var.hostname
  proxmox_host = var.proxmox_host
  clone_id = var.clone_id
}
 