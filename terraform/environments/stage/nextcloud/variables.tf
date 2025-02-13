variable "proxmox_host" {
  type = string
}

variable "ubuntu24_template_name" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "sockets" {
  type = number
  default = 1
}

variable "cores" {
  type = number
  default = 2
}

variable "memory" {
  description = "The amount of memory for the VM in MB"
  type        = number
  default = 4096
}

####### CLOUD INIT VARS #########
variable "ssh_key" {
  description = "SSH public key"
  type        = string
  default     = ""
}

variable "ciuser" {
  description = "Default user for cloud init"
  type        = string
  default     = "pofo14"
}

variable "ipaddress" {
  description = "The IP address to assign to the VM"
  type        = string
  default     = "ip=dhcp"
}

variable "cipassword" {
  description = "Default password for cloud init"
  type        = string
  default     = "ubuntu"
  sensitive   = true
}

