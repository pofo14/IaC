# TrueNAS VM with PCI Passthrough

This Terraform configuration creates a TrueNAS VM with PCI passthrough for storage controllers.

## Architecture

This implementation follows a modular approach:

1. **vm-clone-bgp**: Used to create the base TrueNAS VM from a template
2. **pve-pci-passthrough**: Used to configure PCI passthrough for storage controllers

## Prerequisites

- Proxmox host with IOMMU enabled
- VFIO modules loaded on the host
- A TrueNAS template VM to clone from (VM ID 9000)

## PCI Controller Detection

Before deploying, you can identify available PCI controllers using the utility script:

```bash
# Copy the script to your Proxmox host
scp ../../../../utils/get_pci_controllers.sh root@pve1:/root/

# Run the script on the Proxmox host
ssh root@pve1 'bash /root/get_pci_controllers.sh'
```

Use the output to update the `pci_ids` variable in `main.tf`.

## Customization

You can customize the TrueNAS VM by modifying the variables in `main.tf`:

- `vm_id`: The VM ID for TrueNAS
- `hostname`: The hostname for TrueNAS
- `domain`: The domain name for TrueNAS
- `pci_ids`: List of PCI IDs to pass through to TrueNAS

## Usage

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply
```

## Verification

After applying, verify the PCI passthrough configuration:

```bash
ssh root@pve1 'cat /etc/pve/qemu-server/101.conf | grep hostpci'
```
