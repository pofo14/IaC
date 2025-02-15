module "lxc_container" {
  source = "../../../modules/lxc-template"

  node_name = var.node_name
  ssh_keys = data.sops_file.secrets.data["ssh_keys"]
  hostname = var.hostname
  dns_domain = var.dns_domain
  dns_servers = var.dns_servers
  ip_address = var.ip_address
  unprivileged = var.unprivileged
  os_template_file = proxmox_virtual_environment_download_file.latest_debian_12_lxc_img.id
  cpu_cores = var.cpu_cores
  memory = var.memory
  rootfs_size = var.rootfs_size
  tags = var.tags

  user_password = data.sops_file.secrets.data["host_root_password"] 

}

resource "proxmox_virtual_environment_download_file" "latest_debian_12_lxc_img" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "proxmox"
  url          = "http://download.proxmox.com/images/system/debian-12-standard_12.7-1_amd64.tar.zst"
}
