#!/usr/bin/python
# -*- coding: utf-8 -*-

DOCUMENTATION = '''
---
module: truenas_disk_map
short_description: Creates a dictionary mapping of disk serial numbers to TrueNAS disk names
description:
    - This module uses the TrueNAS API to retrieve disk information
    - It creates a dictionary with disk serial numbers as keys and disk names as values
    - Useful for consistent disk identification in ZFS pool creation
author: "GitHub Copilot"
options:
    api_host:
        description:
            - TrueNAS host address
        required: true
        type: str
    api_user:
        description:
            - TrueNAS username
        required: false
        type: str
    api_password:
        description:
            - TrueNAS password
        required: false
        type: str
    api_key:
        description:
            - TrueNAS API key
        required: false
        type: str
    validate_certs:
        description:
            - Validate HTTPS certificates
        required: false
        default: true
        type: bool
'''

EXAMPLES = '''
- name: Get disk mapping by serial
  truenas_disk_map:
    api_host: "{{ ansible_host }}"
    api_user: "root"
    api_password: "password"
  register: disk_map
'''

RETURN = '''
disks_by_serial:
    description: Dictionary mapping of disk serial numbers to disk names
    returned: success
    type: dict
    sample: { "ABCDEF123456": "sda", "GHIJKL789012": "sdb" }
disks_by_size:
    description: Dictionary mapping of disk sizes to list of disk names
    returned: success
    type: dict
    sample: { "1000GB": ["sda", "sdb"], "500GB": ["sdc"] }
disks_full_info:
    description: Complete disk information as returned by the API
    returned: success
    type: list
'''

import json
import traceback
from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.urls import fetch_url, basic_auth_header

class TrueNASAPIClient:
    def __init__(self, module):
        self.module = module
        self.api_host = module.params['api_host']
        self.api_user = module.params.get('api_user')
        self.api_password = module.params.get('api_password')
        self.api_key = module.params.get('api_key')
        self.validate_certs = module.params.get('validate_certs')
        
        # Ensure the API URL has the correct format
        if not self.api_host.startswith(('http://', 'https://')):
            self.api_host = f"https://{self.api_host}"
        
        # Remove trailing slash if present
        self.api_host = self.api_host.rstrip('/')

    def api_call(self, endpoint, method='GET', data=None):
        url = f"{self.api_host}/api/v2.0/{endpoint}"
        headers = {}
        
        if self.api_key:
            headers['Authorization'] = f"Bearer {self.api_key}"
        elif self.api_user and self.api_password:
            headers['Authorization'] = basic_auth_header(self.api_user, self.api_password)
        
        if data:
            headers['Content-Type'] = 'application/json'
            data = json.dumps(data)
            
        resp, info = fetch_url(
            self.module,
            url,
            method=method,
            data=data,
            headers=headers,
            validate_certs=self.validate_certs
        )
        
        if info['status'] != 200:
            self.module.fail_json(msg=f"API call failed: {info['msg']}", url=url, status_code=info['status'])
            
        content = resp.read()
        return json.loads(content.decode('utf-8'))

    def get_disks(self):
        """Get information about all disks in the system"""
        return self.api_call("disk")

def main():
    module_args = dict(
        api_host=dict(type='str', required=True),
        api_user=dict(type='str', required=False, no_log=True),
        api_password=dict(type='str', required=False, no_log=True),
        api_key=dict(type='str', required=False, no_log=True),
        validate_certs=dict(type='bool', default=False)
    )
    
    module = AnsibleModule(
        argument_spec=module_args,
        required_one_of=[['api_user', 'api_key']],
        required_together=[['api_user', 'api_password']],
        supports_check_mode=True
    )
    
    try:
        client = TrueNASAPIClient(module)
        disks = client.get_disks()
        
        # Create mapping of serial numbers to disk names
        disks_by_serial = {}
        disks_by_size = {}
        
        for disk in disks:
            serial = disk.get('serial', '').strip()
            name = disk.get('name', '')
            size_gb = int(disk.get('size', 0) / (1024 ** 3))
            size_key = f"{size_gb}GB"
            
            # Add to serial map if serial exists
            if serial:
                disks_by_serial[serial] = name
            
            # Group disks by size
            if size_key not in disks_by_size:
                disks_by_size[size_key] = []
            disks_by_size[size_key].append(name)
        
        result = {
            'changed': False,
            'disks_by_serial': disks_by_serial,
            'disks_by_size': disks_by_size,
            'disks_full_info': disks
        }
        
        module.exit_json(**result)
        
    except Exception as e:
        module.fail_json(msg=f"Module failed: {str(e)}", exception=traceback.format_exc())

if __name__ == '__main__':
    main()
