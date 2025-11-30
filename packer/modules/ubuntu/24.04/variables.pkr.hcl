###################################
######### Global Variables ########
###################################
variable "proxmox_api_url" {
  type = string
  description = "Proxmox API URL"
  default = env("PROXMOX_API_URL")
}

variable "proxmox_api_token_id" {
  type = string
  description = "Proxmox API token ID"
  default = env("PROXMOX_API_TOKEN_ID")
}

variable "proxmox_api_token_secret" {
  type = string
  description = "Proxmox API token secret"
  default = env("PROXMOX_API_TOKEN_SECRET")
  sensitive = true
}

variable "proxmox_node" {
  type = string
  description = "Proxmox node name"
  default = env("PROXMOX_NODE")
}

variable "vm_id" {
  type = string
  description = "VM ID for this template"
  default = env("VM_ID")
}

variable "cpu_type" {
  type = string
  default = "x86-64-v2-AES"
  description = "Proxmox CPU type"
}

variable "memory" {
  type = number
  default = 4096
  description = "Memory in MB"
}

variable "cores" {
  type = number
  default = 2
  description = "Number of CPU cores"
}

variable "disk_storage" {
  type        = string
  description = "Proxmox storage pool name used for VM disks."
}

variable "disk_size_gb" {
  type        = number
  default     = 32
  description = "Primary disk size in GiB."
}

variable "network_bridge" {
  type        = string
  default     = "vmbr0"
  description = "Proxmox network bridge to attach VM network adapter."
}

# Environment and node variables (set via auto.pkrvars.hcl)
variable "environment" {
  type = string
  description = "Environment (dev/prod)"
  default = env("ENVIRONMENT")
}

variable "template_description" {
  type        = string
  description = "Description applied to the resulting Proxmox template."
}

##########################################################
######## Ubuntu Specific Variables #####################
##########################################################
variable "ubuntu_version" {}
variable "iso_file" {}
variable "iso_storage_pool" {}
variable "default_ip" {}
variable "cloud_init_storage_pool" {}

variable "default_user_password_hash" {
  type        = string
  description = "Default user password hash (for 'ubuntu' user)"
  default     = env("PKR_VAR_template_user_password_hash")
}

variable "ssh_username" {
  type = string
  description = "SSH User"
  default = env("SSH_USERNAME")
}

variable "github_username" {
  type = string
  description = "Github User"
  default = env("GITHUB_USER")
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "List of SSH public keys to authorize for SSH access"
  default     = []
}

variable "ssh_private_key_file" {
  type        = string
  description = "Path to SSH private key for Packer to use during provisioning"
  default     = "~/.ssh/id_ed25519"
}
