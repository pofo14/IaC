variable "proxmox_host" {
  type = string
}

variable "ubuntu24_template_id" {
  type = string
}

variable "hostname" {
  type = string
}

variable "domain" {
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

variable "tags" {
  type = list(string)
  default = []
}

variable "cpu_type" {
  type = string
  default = "x86-64-v2-AES"
}

variable "description" {
  type = string
  default = "Managed by Terraform"
}

####### CLOUD INIT VARS #########
variable "ipaddress" {
  description = "The IP address to assign to the VM"
  type        = string
  default     = "ip=dhcp"
}

variable "gateway" {
  description = "The IP address to gateway to the VM"
  type        = string
}


