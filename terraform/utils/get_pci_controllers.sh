#!/bin/bash
# filepath: get_pci_controllers.sh
# Usage: Run on your Proxmox host to detect PCI controllers for passthrough
# Copy this script to your Proxmox host and run it to see available PCI controllers

echo "# PCI Controller Detection for Terraform"

# Get all storage controllers
echo -e "\n# Storage Controllers - Copy these IDs for Terraform variables"
echo "# FORMAT: PCI ID | Description"
echo "# ------------------------------------------------------"

# Find LSI/SAS controllers
lspci | grep -i "LSI\|SAS" | while read -r line; do
  pci_id=$(echo "$line" | cut -d' ' -f1)
  echo "\"$pci_id\",  # $line"
done

# Find SATA controllers
lspci | grep -i "SATA" | while read -r line; do
  pci_id=$(echo "$line" | cut -d' ' -f1)
  echo "\"$pci_id\",  # $line"
done

# Find any other SCSI controllers
lspci | grep -i "SCSI" | grep -v "SAS" | while read -r line; do
  pci_id=$(echo "$line" | cut -d' ' -f1)
  echo "\"$pci_id\",  # $line"
done

echo -e "\n# Example Terraform Usage:"
echo "variable \"pci_ids\" {"
echo "  description = \"List of PCI IDs to pass through to TrueNAS\""
echo "  type = list(string)"
echo "  default = ["
lspci | grep -E "LSI|SAS|SATA|SCSI|RAID" | head -3 | while read -r line; do
  pci_id=$(echo "$line" | cut -d' ' -f1)
  echo "    \"$pci_id\",  # $line"
done
echo "  ]"
echo "}"
echo ""
echo "module \"pci_passthrough\" {"
echo "  source = \"../pve-pci-passthrough\""
echo "  vm_id = 101"
echo "  node_name = \"pve1\""
echo "  pci_ids = var.pci_ids"
echo "}"
