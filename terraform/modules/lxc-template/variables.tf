variable "node_name" {
    description = "The Proxmox node name where the container will be created"
    type        = string
}

variable "ssh_keys" {
    description = "The SSH public keys for the user account in the container"
    type        = string
}

variable "hostname" {
    description = "The hostname for the container"
    type        = string
}

variable "dns_domain" {
    description = "The DNS domain for the container"
    type        = string
    default = "flopo.retropetro.net"
}

variable "dns_servers" {
    description = "The DNS servers for the container"
    type        = list(string)
}

variable "ip_address" {
    description = "The IPv4 address for the container"
    type        = string
}

variable "user_password" {
    description = "The password for the user account in the container"
    type        = string
    sensitive   = true
}

variable "cpu_architecture" {
    description = "The CPU architecture for the container"
    type        = string
    default = "amd64"
}

variable "cpu_cores" {
    description = "The number of CPU cores for the container"
    type        = number
    default = 1
}
variable "memory" {
    description = "The amount of memory dedicated to the container"
    type        = number
    default = 512
}

variable "os_template_file" {
    description = "The template file ID for the container's operating system"
    type        = string
}

variable "ostype" {
    description = "The operating system type for the container"
    type        = string
    default = "ubuntu"
}

variable "storage_pool" {
    description = "The storage pool for the container's disk"
    type        = string
    default = "local-zfs"
}

variable "rootfs_size" {
    description = "The size of the container's disk"
    type        = number
    default = "8"
}

variable "mount_points" {
    description = "The mount points for the container"
    type        = map(object({
        storage_pool = string
        disk_size    = string
    }))
    default = {}
}

variable "startup_order" {
    description = "The startup order for the container"
    type        = number
    nullable = true
    default = null
}

variable "up_delay" {
    description = "The delay in seconds before starting the container"
    type        = number
    nullable = true
    default = null
}

variable "down_delay" {
    description = "The delay in seconds before stopping the container"
    type        = number
    nullable = true
    default = null
}

variable "pool_id" {
    description = "The pool ID for the container"
    type        = string
    nullable = true
    default = null
}

variable "unprivileged" {
    description = "Whether the container is unprivileged"
    type        = bool
    default = true
}

variable "tags" {
    description = "Tags for the container"
    type        = list(string)
    default     = []
}