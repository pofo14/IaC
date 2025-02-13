module "mealie_lxc-template" {
  source = "../../../modules/lxc-template"
  providers = {
    proxmox = proxmox
  }

}
 