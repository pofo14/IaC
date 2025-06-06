variable "hostname" {
  description = "The hostname of the VM"
  type        = string
}

variable "domain" {
  description = "The domain to join"
  type        = string
  default = "flopo.retropetro.net"
}

variable "proxmox_host" {
  description = "The Proxmox host to deploy the VM on"
  type        = string
  default = "pve1"
}

variable "cores" {
  description = "The number of CPU cores for the VM"
  type        = number
  default = 2
}

variable "sockets" {
  description = "The number of CPU sockets for the VM"
  type        = number
  default = 1
}

variable "cpu_type" {
  description = "The type of CPU for the VM"
  type        = string
  default = "x86-64-v2-AES"
}

variable "memory" {
  description = "The amount of memory for the VM in MB"
  type        = number
  default = 4096
}

variable "tags" {
  description = "The tags to apply to the VM"
  type        = list(string)
  default = []
}

variable "ssh_keys" {
  description = "The ssh keys to apply to the VM"
  type        = list(string)
  default = []
}

variable "description" {
  description = "The descriptions to apply to the VM"
  type        = string
  default = "Managed by Terraform"
}

variable "disksize" {
  description = "The size of the VM's disk in GB"
  type        = string
  default = "20"
}

variable "storage_pool" {
  description = "The storage pool to use for the VM's disk"
  type        = string
  default = "zfs01"
}

variable "ipaddress" {
  description = "The IP address to assign to the VM"
  type        = string
  default     = "dhcp"
}

variable "gateway" {
  description = "The IP address to gateway to the VM"
  type        = string
}





