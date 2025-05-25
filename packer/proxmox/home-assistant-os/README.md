# Packer Configuration for Home Assistant OS VM Template

This directory contains Packer configuration to build a Proxmox VM template for Home Assistant OS.

## Prerequisites

1.  **Packer Installed:** Ensure Packer is installed on your system.
2.  **Proxmox Environment:**
    *   A running Proxmox VE instance.
    *   Proxmox API token with necessary permissions (e.g., `VM.Allocate`, `VM.Audit`, `VM.Clone`, `VM.Config.CDROM`, `VM.Config.CloudInit`, `VM.Config.CPU`, `VM.Config.Disk`, `VM.Config.HWType`, `VM.Config.Memory`, `VM.Config.Network`, `VM.Config.OS`, `VM.Monitor`, `VM.PowerMgmt`, `Datastore.AllocateSpace`, `Datastore.Audit`, `Sys.Modify`, `SDN.Use`).
3.  **SSH Access to Proxmox Host:** The machine running Packer must be able to SSH to the Proxmox host specified by `proxmox_node` (default: `pve1`). This is used by the `shell-local` provisioner to execute commands on the Proxmox host for downloading and configuring the HAOS disk. Ensure passwordless SSH (via SSH agent or a dedicated key) is set up for the `proxmox_host_ssh_user` (default: `root`).
4.  **Required Tools on Proxmox Host:** The Proxmox host needs `curl`, `unxz`, `mktemp`, and standard Proxmox tools (`qm`, `pvesm`). These are typically present on a standard Proxmox installation.
5.  **Internet Access:** The Proxmox host requires internet access to download the Home Assistant OS image.
6.  **Dummy ISO:** A small ISO (SliTaz Linux by default) is used for initial VM creation by Packer. This will be downloaded automatically by Packer.

## Configuration Variables

The Packer build is controlled by variables defined in `home-assistant-os.pkr.hcl`. Key variables include:

*   `proxmox_api_url`: URL of your Proxmox API.
*   `proxmox_api_token_id`: Your Proxmox API token ID.
*   `proxmox_api_token_secret`: Your Proxmox API token secret.
*   `proxmox_node`: The Proxmox node to build on (default: `pve1`).
*   `vm_id`: Unique ID for the VM template (default: `9000`).
*   `template_name`: Name for the created template (default: `haos-template`).
*   `os_version`: HAOS version (`stable`, `beta`, `dev`; default: `stable`).
*   `cores`, `memory`: VM resources.
*   `storage_pool`: Proxmox storage for the VM disk (default: `local-lvm`).
*   `network_bridge`: Network bridge for the VM (default: `vmbr0`).
*   `proxmox_host_ssh_user`: SSH user for the Proxmox host (default: `root`).
*   `proxmox_host_ssh_private_key_file`: Optional path to an SSH private key for connecting to the Proxmox host.

You can override these variables using a `.pkrvars.hcl` file or environment variables. For example, create `vars.auto.pkrvars.hcl`:

```hcl
// vars.auto.pkrvars.hcl
proxmox_api_url    = "https://your-proxmox-ip-or-fqdn:8006/api2/json"
proxmox_api_token_id = "your_user@pve!your_token_id"
proxmox_api_token_secret = "your_secret_token_value"
// Add other overrides as needed, e.g.:
// proxmox_node = "pve2"
// storage_pool = "local-zfs"
// proxmox_host_ssh_private_key_file = "~/.ssh/id_proxmox"
```

## Build Instructions

1.  Navigate to this directory:
    ```bash
    cd packer/proxmox/home-assistant-os
    ```
2.  Initialize Packer (if using plugins not locally installed, though proxmox plugin is often bundled or auto-downloaded):
    ```bash
    packer init .
    ```
3.  Validate the configuration:
    ```bash
    packer validate .
    # If using var files:
    # packer validate -var-file="vars.auto.pkrvars.hcl" .
    ```
4.  Run the build:
    ```bash
    packer build .
    # If using var files:
    # packer build -var-file="vars.auto.pkrvars.hcl" .
    ```

This will create a new VM template in your Proxmox environment named according to the `template_name` variable.

## Notes

*   The build process involves SSHing to the Proxmox host to perform disk manipulations (`qm importdisk`, `pvesm alloc`, etc.). Ensure the specified SSH user has the necessary permissions (typically root).
*   The Home Assistant OS disk is set to 32GB.
*   The resulting template will have Home Assistant OS installed, ready to be cloned. It should obtain an IP address via DHCP on first boot.
```
