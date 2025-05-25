# Ansible Role: Grafana Dashboards

Manages Grafana dashboards via the Grafana HTTP API. This role can upload dashboards from local JSON files and optionally download community dashboards from Grafana.com.

## Requirements

*   Ansible 2.9 or later.
*   The `grafana.grafana` Ansible collection must be installed:
    ```bash
    ansible-galaxy collection install grafana.grafana
    ```
*   If using dashboard downloads (`dashboard_download: true`), the target host needs internet access to Grafana.com. Python's `requests` library might be needed on the controller if not using `ansible.builtin.uri` directly or if certain modules depend on it. (The current implementation uses `ansible.builtin.uri` which is generally available).

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

| Variable                             | Default                      | Description                                                                                                                               |
| ------------------------------------ | ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `grafana_url`                        | `"http://localhost:3000"`    | URL of the Grafana instance.                                                                                                              |
| `grafana_admin_user`                 | `"admin"`                    | Grafana admin username (used if `grafana_api_key` is not set).                                                                            |
| `grafana_admin_password`             | `""` (commented out)         | Grafana admin password (used if `grafana_api_key` is not set). **Using `grafana_api_key` is strongly recommended for production.**          |
| `grafana_api_key`                    | `""`                         | Grafana API key (Viewer, Editor, or Admin role) for authentication. If set, this takes precedence over user/password. Example: `glsa_...` |
| `dashboard_download`                 | `true`                       | Whether to enable downloading of dashboards from grafana.com.                                                                             |
| `grafana_dashboards_folder_name`     | `"Homelab Dashboards"`       | (Bonus) Name of the folder to create in Grafana for these dashboards.                                                                     |
| `grafana_dashboards_create_folder`   | `true`                       | (Bonus) Whether to create the folder specified by `grafana_dashboards_folder_name`. Dashboards will be placed in this folder if created.   |
| `dashboard_list`                     | (see `defaults/main.yml`)    | A list of dashboards to manage. See "Dashboard List Structure" below for details.                                                         |

### Dashboard List Structure

The `dashboard_list` variable is a list of dictionaries, where each dictionary defines a dashboard.

**For dashboards downloaded from Grafana.com:**

*   `name`: (Required) A descriptive name for the dashboard (e.g., "Proxmox Node Summary").
*   `uid`: (Required) A unique identifier for Grafana to use. This can be custom (e.g., "proxmox-node-summary"). It's used by Grafana to uniquely identify the dashboard, even if the title changes.
*   `source`: Must be set to `'grafana.com'`.
*   `id`: (Required) The numerical dashboard ID from Grafana.com (e.g., `1860`). You can find this in the URL of the dashboard on the Grafana website (e.g., `https://grafana.com/grafana/dashboards/1860-node-exporter-full/`).
*   `filename`: (Optional) Specify a custom filename for the downloaded JSON file (e.g., `"community_node-exporter_1860.json"`). If omitted, a filename will be generated (e.g., `proxmox-node-summary_1860.json`).
*   `revision`: (Optional) Specify a specific dashboard revision number. Defaults to the latest available revision.

**Example (grafana.com):**
```yaml
dashboard_list:
  - name: "Proxmox - Node Summary"
    uid: "proxmox-node-summary"
    source: "grafana.com"
    id: 1860 # !! VERIFY THIS ID on grafana.com !!
    filename: "community_proxmox-node-summary.json"
```

**For dashboards uploaded from local files:**

*   `name`: (Required) A descriptive name for the dashboard (e.g., "My Custom Local Dashboard").
*   `uid`: (Required) A unique identifier for Grafana to use (e.g., "my-custom-dashboard").
*   `path`: (Required) The path to the dashboard JSON file, relative to the `files/` directory within this role (e.g., `"my-local-dashboard.json"`).

**Example (local file):**
```yaml
dashboard_list:
  - name: "My Custom Local Dashboard"
    uid: "my-custom-dashboard"
    path: "my-local-dashboard.json" # File should be at roles/grafana_dashboards/files/my-local-dashboard.json
```

**!! IMPORTANT !!**
The `id` fields for `grafana.com` dashboards in `defaults/main.yml` are examples. **Always verify these IDs on [grafana.com/grafana/dashboards/](https://grafana.com/grafana/dashboards/)** to ensure you get the most up-to-date and suitable versions for your setup.

## Dependencies

*   `grafana.grafana` collection.

## Example Playbook

See the `upload_dashboards.yml` file in the root of this repository for a full example:

```yaml
---
- name: Upload Grafana Dashboards
  hosts: grafana # Ensure this host group is defined in your Ansible inventory
  become: false
  gather_facts: false

  vars:
    # Example of overriding the Grafana URL and API Key
    # grafana_url: "https://mygrafana.example.com"
    # grafana_api_key: "glsa_your_actual_api_key_here"

    custom_dashboard_list:
      - name: "Node Exporter Full (Community)"
        uid: "node-exporter-full-override"
        source: "grafana.com"
        id: 1860 # VERIFY THIS ID
        filename: "community_node-exporter-full_override.json"

      - name: "My Production Dashboard (Local)"
        uid: "prod-server-overview-override"
        path: "production-dashboard.json" # Place in roles/grafana_dashboards/files/

  roles:
    - role: grafana_dashboards
      dashboard_list: "{{ custom_dashboard_list }}"
      # dashboard_download: false # Optionally disable download
      # grafana_dashboards_create_folder: false # Optionally disable folder creation
```

To use this role:
1.  Ensure your Grafana instance is running and accessible.
2.  Define your `grafana` hosts in your Ansible inventory.
3.  Set the `grafana_url` and `grafana_api_key` (recommended) or `grafana_admin_user`/`grafana_admin_password`.
4.  Customize the `dashboard_list` variable with the dashboards you want to manage.
5.  Run your playbook.

## License

MIT

## Author Information

This role was created by an AI assistant.
