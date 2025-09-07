variable "proxmox_host" {
  type = string
}

variable "truenas_template_id" {
  type = string
  default = "9002"
}

variable "hostname" {
  type = string
  default = "test-truenas"
}

variable "domain" {
  type = string
  default = "flopo.retropetro.net"
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
  default = 8192
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