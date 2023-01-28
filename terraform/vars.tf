variable "proxmox_api_var" { 
    default  = "https://192.168.2.165:8006/api2/json" 
}

variable "proxmox_host" {
    default = "pve"
} 

variable "proxmox_api_token_var" {
    default = "tf@pve!tftoken"
}

variable "proxmox_api_token_secret_var" {
    default = "c57e0deb-862a-4126-b2c7-291170c066cd"
}

variable "template_name" {
    default = "jammy-template"
}

variable ssh_key {
    default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGV3A7AjEKrTwp8KnWIvF5z5WzqEH/MrBiP5zE07MQaA ken default"
}