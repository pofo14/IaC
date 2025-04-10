# Proxmox Base Setup Role

This role handles the basic setup of Proxmox, including repository configuration and subscription nag removal.

## Variables

- `proxmox_base_disable_enterprise_repo`: Disable the enterprise repository (default: `true`).
- `proxmox_base_enable_no_subscription_repo`: Enable the no-subscription repository (default: `true`).

## Example Playbook

```yaml
- hosts: proxmox
  roles:
    - role: proxmox_base_setup
```
