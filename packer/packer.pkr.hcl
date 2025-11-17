packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = ">= 1.2.3"
    }

    # If you ever add others, put them here too:
    # ansible = {
    #   source  = "github.com/hashicorp/ansible"
    #   version = ">= 1.1.0"
    # }
  }
}
