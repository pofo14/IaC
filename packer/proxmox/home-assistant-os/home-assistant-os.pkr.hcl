variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API URL (e.g., https://pve.example.com:8006/api2/json)"
  nullable    = false
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API Token ID (e.g., user@pve!packer)"
  nullable    = false
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "Proxmox API Token Secret"
  sensitive   = true
  nullable    = false
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node to build on."
  default     = "pve1"
}

variable "template_name" {
  type        = string
  description = "Name of the Proxmox template to create."
  default     = "haos-template"
}

variable "vm_id" {
  type        = number
  description = "Unique ID for the VM and template."
  default     = 9000
}

variable "os_version" {
  type        = string
  description = "Home Assistant OS version to install (stable, beta, dev)."
  default     = "stable"
}

variable "cores" {
  type        = number
  description = "Number of CPU cores for the VM."
  default     = 2
}

variable "memory" {
  type        = number
  description = "Amount of RAM in MB for the VM."
  default     = 4096
}

variable "storage_pool" {
  type        = string
  description = "Proxmox storage pool for VM disks."
  default     = "local-lvm"
}

variable "network_bridge" {
  type        = string
  description = "Proxmox network bridge for the VM."
  default     = "vmbr0"
}

variable "proxmox_host_ssh_user" {
  type        = string
  description = "SSH username for connecting to the Proxmox host (for shell-local provisioner)."
  default     = "root" 
}

variable "proxmox_host_ssh_private_key_file" {
  type        = string
  description = "Path to SSH private key for connecting to Proxmox host. If not set, ensure ssh-agent or password is configured for the user running Packer."
  default     = "" 
  nullable    = true
}

variable "dummy_iso_url" {
  type    = string
  default = "http://mirror.slitaz.org/iso/rolling/slitaz-rolling-core64.iso"
  description = "URL for a small dummy ISO used for initial VM creation by Packer."
}

variable "dummy_iso_checksum" {
  type    = string
  default = "md5:c8ca4c4ac4a3099f4a6ac729eac09008"
  description = "MD5 checksum for the dummy ISO."
}

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3" 
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox" "haos" {
  proxmox_url = var.proxmox_api_url
  username    = var.proxmox_api_token_id
  token       = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true 

  node        = var.proxmox_node
  vm_id       = var.vm_id
  vm_name     = var.template_name 
  template_description = "Home Assistant OS ${var.os_version} Template (Built by Packer)"

  os          = "l26" 
  bios        = "ovmf" 
  machine     = "i440fx" 

  cores       = var.cores
  memory      = var.memory
  sockets     = 1
  
  qemu_agent  = true 
  scsihw      = "virtio-scsi-pci"

  network_adapters {
    model   = "virtio"
    bridge  = var.network_bridge
    firewall = false 
  }

  iso_url      = var.dummy_iso_url
  iso_checksum = var.dummy_iso_checksum
  iso_storage_pool = var.storage_pool 
  unmount_iso  = true
  
  disks {
    type              = "scsi" 
    disk_size         = "1G"   
    storage_pool      = var.storage_pool
    format            = "raw" 
  }
  
  communicator = "none"
}

build {
  sources = ["source.proxmox.haos"]

  provisioner "shell-local" {
    inline_shebang = "/bin/bash"
    inline = [
      "echo '==> Starting HAOS disk preparation on Proxmox node: ${var.proxmox_node}'",
      "SSH_USER=${var.proxmox_host_ssh_user}",
      "SSH_HOST=${var.proxmox_node}",
      "if [ -n \"${var.proxmox_host_ssh_private_key_file}\" ]; then SSH_KEY_ARG=\"-i ${var.proxmox_host_ssh_private_key_file}\"; else SSH_KEY_ARG=\"\"; fi",
      "echo \"Attempting SSH to $SSH_USER@$SSH_HOST... (Ensure SSH key is in agent or passwordless login for $SSH_USER if no key file specified)\"",
      
      "ssh $SSH_KEY_ARG $SSH_USER@$SSH_HOST <<'PROXMOX_EOF'", # Start of heredoc for SSH script
      "  set -ex",
      "  VMID=${var.vm_id}",
      "  STORAGE_POOL=${var.storage_pool}",
      "  HAOS_VERSION_TYPE=${var.os_version}", 
      "  VM_NAME_PREFIX='haos_packer_temp'",
      
      "  echo '--- Running on Proxmox Node: $(hostname) ---'",
      "  echo \"VMID: $VMID, Storage: $STORAGE_POOL, HAOS Type: $HAOS_VERSION_TYPE\"",

      "  HAOS_OVA_VERSION=$(curl -sSL https://raw.githubusercontent.com/home-assistant/version/master/${HAOS_VERSION_TYPE}.json | grep '\"ova\"' | cut -d '\"' -f 4)",
      "  if [ -z \"$HAOS_OVA_VERSION\" ]; then echo 'Error: Failed to get HAOS OVA version string.' >&2; exit 1; fi",
      "  echo \"Resolved HAOS Download Version (from ova field): $HAOS_OVA_VERSION\"",
      
      "  if [ \"${HAOS_VERSION_TYPE}\" == \"dev\" ]; then",
      "    DOWNLOAD_URL=\"https://os-artifacts.home-assistant.io/${HAOS_VERSION_TYPE}/haos_ova-${HAOS_VERSION_TYPE}.qcow2.xz\"",
      "  else",
      "    DOWNLOAD_URL=\"https://github.com/home-assistant/operating-system/releases/download/${HAOS_OVA_VERSION}/haos_ova-${HAOS_OVA_VERSION}.qcow2.xz\"",
      "  fi",
      "  echo \"HAOS Download URL: $DOWNLOAD_URL\"",
      
      "  TEMP_DIR=$(mktemp -d \"/var/tmp/${VM_NAME_PREFIX}_XXXXXX\")", # Ensure quotes for mktemp path
      "  echo \"Temporary directory for download: $TEMP_DIR\"",
      "  cd \"$TEMP_DIR\"",
      "  QCOW_FILE_XZ=\"haos_ova-${HAOS_OVA_VERSION}.qcow2.xz\"",
      "  QCOW_FILE=\"haos_ova-${HAOS_OVA_VERSION}.qcow2\"",
      
      "  echo 'Downloading HAOS image...'",
      "  curl -fL -o \"$QCOW_FILE_XZ\" \"$DOWNLOAD_URL\"",
      "  echo 'Download complete. Extracting HAOS image...'",
      "  unxz -T0 \"$QCOW_FILE_XZ\"",
      "  echo \"Extraction complete: $QCOW_FILE\"",

      "  echo 'Detaching and removing initial dummy disk(s)...'",
      "  QM_CONFIG=$(qm config $VMID)",
      "  DELETE_CMD_ARGS=\"\"", # Store arguments for qm set --delete
      "  for i in {0..3}; do for type in scsi sata ide virtio; do", # Check common disk types and indices
      "    if echo \"$QM_CONFIG\" | grep -q \"^${type}${i}:\"; then",
      "      if ! echo \"$QM_CONFIG\" | grep -q \"^${type}${i}:.*,media=cdrom\"; then", # Don't remove CDROM drive itself
      "        DELETE_CMD_ARGS=\"$DELETE_CMD_ARGS --delete ${type}${i}\"",
      "      fi",
      "    fi",
      "  done; done",
      "  for i in {0..15}; do", # Check for unused disks
      "    if echo \"$QM_CONFIG\" | grep -q \"^unused${i}:\"; then",
      "      DELETE_CMD_ARGS=\"$DELETE_CMD_ARGS --delete unused${i}\"",
      "    fi",
      "  done",
      "  if [ -n \"$DELETE_CMD_ARGS\" ]; then",
      "    echo \"Found devices to detach: $DELETE_CMD_ARGS\"",
      "    qm set $VMID $DELETE_CMD_ARGS", # Call qm set with all --delete arguments
      "  else",
      "    echo 'No specific dummy storage disks found/left to detach (CDROM itself is preserved if it was on ide2 for example).'",
      "  fi",
      
      "  echo 'Allocating EFI disk (4M) as vm-${VMID}-disk-0...'",
      "  pvesm alloc $STORAGE_POOL $VMID \"vm-${VMID}-disk-0\" 4M", # Explicitly name the EFI disk
      
      "  echo \"Importing HAOS qcow2 image to $STORAGE_POOL (will be vm-${VMID}-disk-1)...\"",
      "  qm importdisk $VMID \"$QCOW_FILE\" $STORAGE_POOL -format qcow2", # Import, Proxmox names it vm-<vmid>-disk-<next_idx>
      
      "  echo 'Configuring VM with EFI disk (vm-${VMID}-disk-0) and HAOS disk (vm-${VMID}-disk-1), setting boot order...'",
      "  qm set $VMID \\\\", # Use escaped backslash for line continuation in the heredoc
      "    --efidisk0 ${STORAGE_POOL}:vm-${VMID}-disk-0,efitype=4m \\\\",
      "    --scsi0 ${STORAGE_POOL}:vm-${VMID}-disk-1,cache=writethrough,discard=on,ssd=1 \\\\",
      "    --boot order=scsi0",
      
      "  echo \"Resizing HAOS disk (scsi0 / vm-${VMID}-disk-1) to 32G...\"",
      "  qm resize $VMID scsi0 32G",

      "  echo 'Cleaning up temporary files on Proxmox node...'",
      "  rm -rf \"$TEMP_DIR\"",
      "  echo '--- HAOS disk preparation complete on Proxmox Node ---'",
      "PROXMOX_EOF", # End of heredoc
      "echo '==> shell-local provisioner finished.'"
    ]
  }
}
