# Environment-specific variables
variable "vm_id" {
  type = number
  default = 9002
  description = "VM ID for this template"
}

variable "template_name" {
  type = string
  default = "TrueNAS-25.04-template"
  description = "Template name"
}

variable "memory" {
  type = number
  default = 8192
  description = "Memory in MB"
}

variable "cores" {
  type = number
  default = 2
  description = "Number of CPU cores"
} 