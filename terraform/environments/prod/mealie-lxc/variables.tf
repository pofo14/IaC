variable "proxmox_host" {
  type = string
}

variable "hostname" {
  type = string
}

variable "clone_id" {
  description = "ID of the LXC to clone"
  type        = string
}

