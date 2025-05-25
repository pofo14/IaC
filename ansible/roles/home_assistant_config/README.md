# Ansible Role: home_assistant_config

This role configures a Home Assistant instance, focusing on managing configuration files and setting up a basic structure.

## Requirements

*   Ansible 2.12 or higher.
*   Target machine should be a running Home Assistant OS instance (or a Home Assistant Supervised/Container setup where the configuration path is known).
*   SSH access to the Home Assistant machine with a user that has permissions to write to the Home Assistant configuration directory (e.g., `/config` or `/usr/share/hassio/homeassistant`). This often means connecting as `root` or a user with appropriate sudo privileges, as the role uses `become: true`.

## Role Variables

Available variables are listed in `defaults/main.yml`. Key variables include:

*   `ha_config_base_path`: The base directory for Home Assistant configuration files on the target VM. Default: `/config` (common for HAOS).
*   `ha_config_owner`: User that should own the configuration files. Default: `root`.
*   `ha_config_group`: Group for the configuration files. Default: `root`.
    *   Note: For HAOS, file ownership and permissions within the `/config` directory are managed by Home Assistant itself. Running Ansible as `root` and setting files as `root:root` is usually fine, as HA services run with sufficient privilege to access them.
*   `ha_include_dirs`: A list of subdirectories to create within `ha_config_base_path` for organizing configuration (e.g., `automations`, `scripts`, `lovelace`).
*   `ha_instance_name`: Name of the Home Assistant instance (e.g., "My Smart Home").
*   `ha_latitude`, `ha_longitude`, `ha_elevation`: Location settings.
*   `ha_unit_system`: `metric` or `imperial`.
*   `ha_time_zone`: Olson timezone string (e.g., `America/New_York`).
*   `ha_country`: Two-letter ISO country code.
*   `ha_currency`: Three-letter ISO currency code.
*   `ha_default_components`: A list of default Home Assistant components to ensure are implicitly loaded (useful if not relying entirely on `default_config:`).

## Dependencies

None.

## Example Playbook

The primary playbook for using this role is `ansible/playbooks/deploy_home_assistant.yml`:

```yaml
---
- name: Deploy and Configure Home Assistant
  hosts: homeassistant_vms # Target group from your Ansible inventory
  gather_facts: true
  become: true

  vars:
    # Override role defaults here if needed, for example:
    # ha_time_zone: "Europe/London"
    # ha_latitude: 51.5074
    # ha_longitude: 0.1278

  roles:
    - role: home_assistant_config
      # Tags can be used to run specific parts of the role, e.g.:
      # tags: ['core_config'] 
```

## Role Tasks Overview

*   Ensures the base configuration directory and include subdirectories exist.
*   Templates the main `configuration.yaml` file.
*   Creates boilerplate/empty YAML files for includes like `automations.yaml`, `scripts.yaml`, and `scenes.yaml`.
*   Sets up a basic `ui-lovelace.yaml` if managing Lovelace in YAML mode.

## Handlers

*   **Restart Home Assistant**: A placeholder handler is defined. In a production setup, this should be implemented to properly restart Home Assistant (e.g., using `ha cli` or an API call if SSHing as root, or using `community.home_assistant.homeassistant_restart` if API access is configured).

## Usage

1.  **Update Ansible Inventory:** Ensure your Home Assistant VM is defined in your Ansible inventory (e.g., `inventories/production/hosts`) under the `homeassistant_vms` group, with correct `ansible_host` and `ansible_user` details.
    ```ini
    [homeassistant_vms]
    homeassistant ansible_host=YOUR_HA_VM_IP ansible_user=root # Or your HA SSH user
    ```
2.  **Customize Variables (Optional):**
    *   Modify defaults in `defaults/main.yml`.
    *   Override variables in your playbook or inventory `group_vars` / `host_vars`.
    *   For sensitive data (API keys, etc.), consider using Ansible Vault and the `ansible.builtin.lookup('community.sops.sops', 'secrets.sops.yaml')` plugin (requires SOPS setup) or direct Vault encrypted files.
3.  **Run the Playbook:**
    ```bash
    ansible-playbook -i inventories/production/hosts playbooks/deploy_home_assistant.yml
    ```

## Managing Configuration Files

*   **`configuration.yaml`**: Managed by `templates/configuration.yaml.j2`.
*   **Included YAML Files**: Boilerplate files like `automations.yaml` are created. You can manage their content by:
    *   Replacing the `ansible.builtin.copy` task for these with `ansible.builtin.template` if you want to use Jinja2 templating for them.
    *   Creating separate files under the role's `files/` or `templates/` directory and copying them over.
*   **Lovelace Dashboards**:
    *   A basic `ui-lovelace.yaml` is created.
    *   To manage multiple dashboards or more complex Lovelace setups in YAML, place your dashboard YAML files in `ansible/roles/home_assistant_config/files/lovelace_dashboards/` and uncomment/adapt the `ansible.posix.synchronize` task in `tasks/main.yml`.
*   **Custom Components & Other Files**: Use tasks like `ansible.builtin.copy` or `ansible.posix.synchronize` to manage other files and directories within the HA configuration path.
```
