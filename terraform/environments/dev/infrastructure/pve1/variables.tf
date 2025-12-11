// filepath: /workspaces/IaC/terraform/environments/dev/infrastructure/pve1/variables.tf
variable "node_name" {
  description = "Proxmox node name"
  type        = string
  default     = "pve1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
