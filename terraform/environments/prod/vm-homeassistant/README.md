# Terraform Configuration for Home Assistant OS VM

This directory contains Terraform configuration to provision a Home Assistant OS Virtual Machine on Proxmox by cloning the template created by Packer.

## Prerequisites

1.  **Terraform Installed:** Ensure Terraform is installed on your system.
2.  **Proxmox Provider Configured:** Your Terraform environment must be configured with the Proxmox provider. This typically involves setting environment variables like `PM_API_URL`, `PM_USER`, `PM_PASS` or `PM_API_TOKEN_ID` and `PM_API_TOKEN_SECRET`, or configuring the provider block directly. This configuration assumes the provider is configured globally or in a root module.
3.  **Packer-Built Template:** A Home Assistant OS VM template must already exist in Proxmox, built by the Packer configuration in `packer/proxmox/home-assistant-os/`. The default template name expected is `haos-template`.
4.  **SSH Key:** You should have an SSH public key ready to be injected into the VM for Ansible access.

## Configuration Variables

The Terraform deployment is controlled by variables defined in `variables.tf`. Key variables include:

*   `proxmox_node`: Proxmox node where the VM will be cloned (default: `pve1`).
*   `haos_template_name`: Name of the HAOS Proxmox template to clone (default: `haos-template`).
*   `haos_vm_name`: Hostname for the new VM (default: `homeassistant`).
*   `haos_cores`, `haos_memory`: VM resources.
*   `haos_disk_size`: Disk size (should match template, default: `32G`).
*   `haos_storage_pool`: Storage pool for the VM's disk (default: `local-lvm`).
*   `haos_network_bridge`: Network bridge for the VM (default: `vmbr0`).
*   `haos_ip_address_cidr`: Optional static IP in CIDR format (e.g., `192.168.1.100/24`). If empty, DHCP is used.
*   `haos_gateway`: Gateway if using static IP.
*   `haos_nameserver`: DNS server.
*   `haos_ssh_public_key`: Your public SSH key string.

You can override these variables using a `terraform.tfvars` file or by passing them on the command line. For example, create `terraform.tfvars`:

```hcl
// terraform.tfvars
haos_vm_name         = "my-home-assistant"
haos_ip_address_cidr = "192.168.1.50/24"
haos_gateway         = "192.168.1.1"
haos_ssh_public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQ..." // Paste your actual public key
// Add other overrides as needed
```

## Deployment Instructions

1.  Navigate to this directory:
    ```bash
    cd terraform/environments/prod/vm-homeassistant
    ```
2.  Initialize Terraform:
    ```bash
    terraform init
    ```
3.  Review the plan:
    ```bash
    terraform plan
    # If using .tfvars:
    # terraform plan -var-file="terraform.tfvars"
    ```
4.  Apply the configuration:
    ```bash
    terraform apply
    # If using .tfvars:
    # terraform apply -var-file="terraform.tfvars"
    ```

This will provision a new Home Assistant OS VM by cloning the specified template.

## Post-Provisioning

*   **IP Address:** If using DHCP, you may need to check your DHCP server or use mDNS (`homeassistant.local`) to find the VM's IP address. The `terraform output haos_vm_ip_address` command might provide it if discoverable.
*   **SSH Access:** The configuration attempts to inject the provided SSH public key via cloud-init. Home Assistant OS may or may not pick this up immediately for the root user or a default user. Initial SSH access might require:
    *   Checking if SSH is enabled on port 22 with the injected key.
    *   Accessing the VM via the Proxmox console to enable SSH or set up users/keys if the cloud-init injection doesn't work as expected for HAOS. HAOS has its own onboarding process.
*   **Ansible:** Once the VM is up and SSH access is confirmed, you can configure it using the Ansible playbook found in `ansible/playbooks/deploy_home_assistant.yml`. Update your Ansible inventory with the VM's IP address and appropriate SSH user.

## Important Notes on `vm-clone` Module

*   **Disk Cloning:** This Terraform configuration uses a general `vm-clone` module. The HAOS template has its primary disk on `scsi0`. The `vm-clone` module might have its own disk definitions (e.g., for `virtio0`). Ensure the module correctly clones the template's disk as-is, including its controller type and size. If the module attempts to define a new, separate disk, it might not properly clone the OS disk. This may require adjustments to the `vm-clone` module itself or careful variable settings.
*   **Cloud-Init with HAOS:** Home Assistant OS has its own way of handling first boot and configuration. While Proxmox will provide a cloud-init drive with the settings specified (like SSH keys and potentially network config), HAOS's uptake of these settings can vary. SSH key injection is the primary goal here for automation. Network settings might fall back to DHCP.
```
