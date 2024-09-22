variable "proxmox_api_var" { 
    default  = "https://192.168.2.165:8006/api2/json" 
}

variable "proxmox_host" {
    default = "pve"
} 
# 5b9r^@5$aUsCWR3%

variable "proxmox_api_token_var" {
    default = "terraform-user@pve!tfe-token"
}

variable "proxmox_api_token_secret_var" {
    default = "cb3e862a-c126-46f1-963d-ef8b8e0ab7ce"
}

variable "template_name" {
    default = "jammy-template-2"
    #default = "jammy-ubuntu"
}

# TODO: Need to make this a list and include the Ansible SSH key to be installed by default
# TODO: Need to ensure no passphrase is required
variable ssh_key {
    default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGV3A7AjEKrTwp8KnWIvF5z5WzqEH/MrBiP5zE07MQaA ken default"           
}

variable ciuser {
  default = "pofo14"
}

variable env {
    default = "dev"
}

variable "vm_type" {
  default = "workload"
}

variable "vm_name" {
    default = "test"
}

#variable "server_hostname" {
#  default = "${var.env}-${var.vm_type}-${var.vm_name}"
#}
