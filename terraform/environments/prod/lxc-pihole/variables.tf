variable "node_name" {
  description = "The Proxmox node name where the container will be created"
  type = string
  default = "proxmox"
}

variable "ssh_keys" {
  description = "The SSH public keys for the user account in the container"
  type = list(string)
  default     = []  # Make it optional with empty default
}

variable "hostname" {
  description = "The hostname for the container"
  type = string
}

variable "dns_domain" {
  description = "The DNS domain for the container"
  type = string
}

variable "dns_servers" {
    description = "The DNS servers for the container"
    type        = list(string)
}

variable "ip_address" {
  description = "The IPv4 address for the container"
  type = string
  default = "dhcp"
}

variable "user_password" {
  description = "The password for the user account in the container"
  type = string
  sensitive = true
  default = "abc123"
}

variable "cpu_cores" {
  description = "The number of CPU cores for the container"
  type = number
  default = 1
}

variable "memory" {
  description = "The amount of memory in MB for the container"
  type = number
  default = 512
}

variable "os_template_file" {
  description = "The OS template to use for the container"
  type = string
}

variable "ostype" {
    description = "The operating system type for the container"
    type        = string
    nullable = true
}

variable "rootfs_size" {
  description = "The size of the root filesystem in GB"
  type = number
  default = "8"
}

variable "startup_order" {
    description = "The startup order for the container"
    type        = number
    default = 1
}

variable "unprivileged" {
  description = "Whether the container should be unprivileged"
  type = bool
  default = true
}

variable "tags" {
  description = "Tags for the container"
  type = list(string)
  default = []
}