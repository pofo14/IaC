# ============================================================================
# VM Definitions - All VMs deployed to pve01 node
# ============================================================================
# Define all VMs as data structures for cleaner management
# Use locals for VM-specific configuration, variables for shared settings

locals {
  # --------------------------------------------------------------------------
  # TrueNAS Files - Primary NAS Appliance
  # --------------------------------------------------------------------------
  truenas_files = {
    hostname    = "files"
    ipaddress   = "10.10.20.10/24"
    template_id = var.truenas_template_id

    # Hardware - Optimized for ZFS performance
    cores            = 6
    sockets          = 1
    cpu_type         = "host" # Host passthrough for best ZFS performance
    memory           = 65536  # 64GB (1GB per TB + 8GB base)
    disksize         = "128"  # Ignored when skip_disk_config=true
    machine          = "q35"  # q35 required for PCI device mappings in Proxmox 9
    skip_disk_config = true   # Don't override template disk (TrueNAS pre-installed)

    # PCI Passthrough - HBA for direct disk access
    pci_mappings = ["hba-lsi-sas-9300-8i"]
    pci_passthrough_options = {
      rombar = false # Required for HBA to boot properly
      xvga   = false
    }
    vlan_tag = 20 # Storage VLAN for NAS traffic

    # Storage - Extra disks not needed with HBA passthrough
    add_extra_disk = false
    extra_disks    = []

    # Cloud-init disabled - TrueNAS pre-installed template doesn't support it
    cloud_init_enabled = false

    # Metadata
    tags        = ["truenas", "nas", "storage", "prod"]
    description = "TrueNAS SCALE - Primary NAS for Media, ROM Collections, and Backups | Managed by Terraform"
  }

  # --------------------------------------------------------------------------
  # Docker Hosts - Container Runtime VMs
  # --------------------------------------------------------------------------
  # Use for_each in main.tf to create multiple identical Docker hosts
  docker_hosts = {
    docker01 = {
      hostname    = "docker01"
      ipaddress   = "10.10.10.11/24"
      template_id = var.ubuntu24_template_id

      cores    = 4
      sockets  = 1
      cpu_type = "x86-64-v2-AES"
      memory   = 8192  # 8GB
      disksize = "100" # 100GB for container images/volumes

      pci_mappings   = []
      add_extra_disk = false
      extra_disks    = []

      cloud_init_enabled = true
      cloud_init_file    = "cloud-init-docker.yml"

      tags        = ["docker", "containers", "prod"]
      description = "Docker Host 01 - Container Runtime | Managed by Terraform"
    }

    docker02 = {
      hostname    = "docker02"
      ipaddress   = "10.10.10.12/24"
      template_id = var.ubuntu24_template_id

      cores    = 4
      sockets  = 1
      cpu_type = "x86-64-v2-AES"
      memory   = 8192 # 8GB
      disksize = "100"

      pci_mappings   = []
      add_extra_disk = false
      extra_disks    = []

      cloud_init_enabled = true
      cloud_init_file    = "cloud-init-docker.yml"

      tags        = ["docker", "containers", "prod"]
      description = "Docker Host 02 - Container Runtime | Managed by Terraform"
    }
  }

  # --------------------------------------------------------------------------
  # Management VMs - Utilities and Infrastructure Services
  # --------------------------------------------------------------------------
  management_vms = {
    management = {
      hostname    = "management"
      ipaddress   = "192.168.2.7/24"
      template_id = var.ubuntu24_template_id

      cores    = 2
      sockets  = 1
      cpu_type = "x86-64-v2-AES"
      memory   = 2048 # 2GB
      disksize = "64"

      pci_mappings   = []
      add_extra_disk = false
      extra_disks    = []

      cloud_init_enabled = true
      cloud_init_file    = "cloud-init-management.yml"

      tags        = ["management", "vm", "proxmox"]
      description = "Management VM for Proxmox Node - hosts PXE | Managed by Terraform"
    }
  }

  # --------------------------------------------------------------------------
  # Utility: GitHub SSH Keys for Cloud-Init
  # --------------------------------------------------------------------------
  # Shared across all VMs that use cloud-init
  github_ssh_keys = data.github_ssh_keys.pofo14_ssh_keys.keys
}
