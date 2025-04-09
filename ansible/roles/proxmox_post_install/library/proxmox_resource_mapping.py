#!/usr/bin/python
__metaclass__ = type

DOCUMENTATION = '''
---
module: proxmox_resource_mapping
short_description: Manage Proxmox resource mappings
description:
  - Create, update, or delete resource mappings in Proxmox VE using the API
options:
  api_host:
    description: The Proxmox VE API host
    required: true
    type: str
  api_token_id:
    description: API token ID
    required: true
    type: str
  api_token_secret:
    description: API token secret
    required: true
    type: str
  validate_certs:
    description: Verify SSL certificate
    type: bool
    default: false
  id:
    description: Resource mapping ID/name
    required: true
    type: str
  type:
    description: Resource type
    type: str
    default: pci
  node:
    description: Proxmox node name
    required: true
    type: str
  pci_device:
    description: PCI device address
    required: true
    type: str
  description:
    description: Optional description
    type: str
    default: ''
  state:
    description: State of the resource mapping
    type: str
    choices: [ present, absent ]
    default: present
'''

EXAMPLES = '''
- name: Create PCI resource mapping
  proxmox_resource_mapping:
    api_host: proxmox.example.com
    api_token_id: "user@pam!token"
    api_token_secret: "secret"
    id: "HBA_01"
    type: "pci"
    node: "proxmox"
    pci_device: "0000:03:00.0"
    description: "LSI HBA Controller"
    state: present
'''

import json
from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.urls import fetch_url
import urllib.parse

def proxmox_api_call(module, method, url, data=None):
    headers = {
        'Authorization': f'PVEAPIToken={module.params["api_token_id"]}={module.params["api_token_secret"]}',
        'Content-Type': 'application/json'
    }
    
    api_url = f'https://{module.params["api_host"]}:8006/api2/json/{url}'
    
    resp, info = fetch_url(
        module,
        api_url,
        data=json.dumps(data) if data else None,
        headers=headers,
        method=method
    )
    
    if info['status'] >= 400:
        module.fail_json(msg=f"API request failed: {info['msg']}")
    
    if resp:
        return json.loads(resp.read())
    return None

def main():
    module = AnsibleModule(
        argument_spec=dict(
            api_host=dict(type='str', required=True),
            api_token_id=dict(type='str', required=True, no_log=True),
            api_token_secret=dict(type='str', required=True, no_log=True),
            validate_certs=dict(type='bool', default=False),
            id=dict(type='str', required=True),
            type=dict(type='str', default='pci'),
            node=dict(type='str', required=True),
            pci_device=dict(type='str', required=True),
            description=dict(type='str', default=''),
            state=dict(type='str', default='present', choices=['present', 'absent']),
        ),
        supports_check_mode=True
    )

    result = dict(
        changed=False,
        mapping=None
    )

    # Get current resource mappings
    current_mappings = proxmox_api_call(module, 'GET', 'cluster/resources')
    
    # Find if our mapping exists
    existing_mapping = None
    for mapping in current_mappings.get('data', []):
        if mapping.get('id') == module.params['id']:
            existing_mapping = mapping
            break

    if module.params['state'] == 'present':
        mapping_data = {
            'id': module.params['id'],
            'type': module.params['type'],
            'node': module.params['node'],
            'pci': module.params['pci_device'],
            'description': module.params['description']
        }

        if not existing_mapping:
            if not module.check_mode:
                result['mapping'] = proxmox_api_call(
                    module,
                    'POST',
                    'cluster/resources',
                    mapping_data
                )
            result['changed'] = True
        else:
            # Check if update needed
            needs_update = any(
                existing_mapping.get(k) != v
                for k, v in mapping_data.items()
            )
            
            if needs_update:
                if not module.check_mode:
                    result['mapping'] = proxmox_api_call(
                        module,
                        'PUT',
                        f'cluster/resources/{module.params["id"]}',
                        mapping_data
                    )
                result['changed'] = True
            else:
                result['mapping'] = existing_mapping

    elif module.params['state'] == 'absent' and existing_mapping:
        if not module.check_mode:
            proxmox_api_call(
                module,
                'DELETE',
                f'cluster/resources/{module.params["id"]}'
            )
        result['changed'] = True

    module.exit_json(**result)

if __name__ == '__main__':
    main()
