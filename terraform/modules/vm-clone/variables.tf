variable "vm_name" {
  description = "The name of the VM"
  type        = string
}

variable "proxmox_host" {
  description = "The Proxmox host to deploy the VM on"
  type        = string
  default = "proxmox"
}

variable "template_name" {
  description = "The name of the template to clone for this VM"
  type        = string
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

variable "memory" {
  description = "The amount of memory for the VM in MB"
  type        = number
  default = 2048
}

variable "tags" {
  description = "The tags to apply to the VM"
  type        = string
  default = ""
}

variable "desc" {
  description = "The descriptions to apply to the VM"
  type        = string
  default = ""
}

variable "disksize" {
  description = "The size of the VM's disk in GB"
  type        = string
  default = "20G"
}

variable "storage_pool" {
  description = "The storage pool to use for the VM's disk"
  type        = string
  default = "zfsdata01"
}

variable "timezone" {
  description = "The timezone for the VM"
  type        = string
  default     = "America/New_York"
}

variable "ssh_keys" {
  description = "The SSH keys to inject into the VM"
  type        = string
  default     = ""
}

variable "ipaddress" {
  description = "The IP address to assign to the VM"
  type        = string
  default     = "ip=dhcp"
}

variable "nameserver" {
  description = "The DNS Server to assign to the VM"
  type        = string
  default     = "192.168.2.2"
}


variable "searchdomain" {
  description = "DNS search domain suffix"
  type        = string
  default     = "flopo.retropetro.net"
}

variable "ciuser" {
  description = "The default user for the VM"
  type        = string
  default     = "pofo14"
}

variable "cipassword" {
  description = "The default password for the VM"
  type        = string
  default     = "password"
  sensitive   = true
}





