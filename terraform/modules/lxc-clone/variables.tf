variable "hostname" {
  description = "The name of the LXC"
  type        = string
}

variable "proxmox_host" {
  description = "The Proxmox host to deploy the VM on"
  type        = string
  default = "proxmox"
}

variable "clone_id" {
  description = "The ID of the LXC to clone"
  type        = string
}





