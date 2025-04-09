#!/usr/bin/python
# -*- coding: utf-8 -*-

DOCUMENTATION = r'''
---
module: truenas_system
short_description: Manage TrueNAS system settings
description:
    - This module allows managing TrueNAS system settings.
options:
    hostname:
        description:
            - The TrueNAS hostname.
        required: false
        type: str
    domain:
        description:
            - The domain name for TrueNAS.
        required: false
        type: str
    api_url:
        description:
            - URL of the TrueNAS system.
        required: true
        type: str
    api_key:
        description:
            - API key for authenticating with the TrueNAS API.
        required: true
        type: str
    validate_certs:
        description:
            - Validate SSL certificates.
        required: false
        default: false
        type: bool
author:
    - "Your Name"
'''

EXAMPLES = r'''
- name: Set TrueNAS domain
  truenas_system:
    domain: example.com
    api_url: https://truenas.local
    api_key: your_api_key
'''

RETURN = r'''
original_settings:
    description: Original system settings before update
    type: dict
    returned: always
domain:
    description: The updated domain value
    type: str
    returned: when setting domain
changed:
    description: Whether the system was changed
    type: bool
    returned: always
'''

from ansible.module_utils.basic import AnsibleModule
import json
import ssl
import urllib.request
import urllib.error
import urllib.parse
import websocket

def get_websocket_connection(module, base_url, auth_header, validate_certs):
    parsed_url = urllib.parse.urlparse(base_url.rstrip('/'))
    ws_host = parsed_url.netloc
    ws_url = f"ws://{ws_host}/websocket"
    
    module.debug(f"Creating WebSocket connection to: {ws_url}")
    
    ws = websocket.create_connection(
        ws_url,
        sslopt={"cert_reqs": ssl.CERT_NONE} if not validate_certs else {},
        timeout=10,
        header=[]  # Empty header for initial connection
    )
    
    # Authenticate with API key
    auth_request = {
        "id": str(1),
        "msg": "connect",
        "version": "1",
        "support": ["1"]
    }
    
    module.debug("Sending WebSocket connect request")
    ws.send(json.dumps(auth_request))
    connect_response = json.loads(ws.recv())
    module.debug(f"WebSocket connect response: {connect_response}")
    
    if connect_response.get('msg') != 'connected':
        ws.close()
        return None, f"Failed to establish WebSocket connection: {connect_response}"
    
    # Now authenticate with the API key
    auth_request = {
        "id": str(2),
        "msg": "method",
        "method": "auth.login_with_api_key",
        "params": [auth_header]
    }
    
    module.debug("Sending WebSocket auth request")
    ws.send(json.dumps(auth_request))
    auth_response = json.loads(ws.recv())
    module.debug(f"WebSocket auth response: {auth_response}")
    
    if not auth_response.get("result"):
        ws.close()
        return None, f"WebSocket authentication failed: {auth_response}"
        
    return ws, None

def get_system_general(module, api_url, auth_header, validate_certs):
    try:
        # Try websocket first as it's more reliable
        ws, error = get_websocket_connection(module, api_url, auth_header, validate_certs)
        if error:
            raise Exception(error)
            
        # Get config
        get_request = {
            "id": str(3),
            "msg": "method",
            "method": "system.general.config",
            "params": []
        }
        
        module.debug("Sending WebSocket get request")
        ws.send(json.dumps(get_request))
        get_response = json.loads(ws.recv())
        module.debug(f"WebSocket get response: {get_response}")
        
        ws.close()
        
        if "result" in get_response:
            return get_response["result"], None
        else:
            return None, f"Failed to get config: {get_response}"
            
    except Exception as e:
        module.debug(f"WebSocket error: {str(e)}")
        return None, f"Failed to get settings: {str(e)}"

def update_system_general(module, api_url, auth_header, validate_certs, update_data):
    try:
        ws, error = get_websocket_connection(module, api_url, auth_header, validate_certs)
        if error:
            raise Exception(error)
        
        # Get current config
        get_request = {
            "id": str(3),
            "msg": "method",
            "method": "system.general.config",
            "params": []
        }
        ws.send(json.dumps(get_request))
        current_config = json.loads(ws.recv())
        module.debug(f"Current config: {current_config}")
        
        if "result" in current_config:
            # Create minimal update payload with only allowed fields
            update_payload = {}
            
            # Only include fields we want to update
            if 'hostname' in update_data:
                update_payload['hostname'] = update_data['hostname']
            if 'domain' in update_data:
                update_payload['domain'] = update_data['domain']
            
            # Required fields from current config
            if 'ui_certificate' in current_config['result']:
                update_payload['ui_certificate'] = current_config['result']['ui_certificate']['id']
            
            # Add other required fields with their current values
            required_fields = ['language', 'timezone', 'kbdmap']
            for field in required_fields:
                if field in current_config['result']:
                    update_payload[field] = current_config['result'][field]
            
            update_request = {
                "id": str(4),
                "msg": "method",
                "method": "system.general.update",
                "params": [update_payload]
            }
            
            module.debug(f"Sending update request: {json.dumps(update_request)}")
            ws.send(json.dumps(update_request))
            update_response = json.loads(ws.recv())
            module.debug(f"Update response: {update_response}")
            
            ws.close()
            
            if "result" in update_response:
                return update_response["result"], None
            elif "error" in update_response:
                return None, f"Failed to update config: {update_response['error']}"
        else:
            return None, f"Failed to get current config: {current_config}"
            
    except Exception as e:
        module.debug(f"WebSocket update failed: {str(e)}")
        return None, f"Failed to update settings: {str(e)}"

def run_module():
    module_args = dict(
        hostname=dict(type='str', required=False),
        domain=dict(type='str', required=False),
        api_url=dict(type='str', required=True),
        api_key=dict(type='str', required=True, no_log=True),
        validate_certs=dict(type='bool', required=False, default=False)
    )

    result = dict(
        changed=False,
        debug_info=[]
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # Add debug method to module
    def debug(msg):
        result['debug_info'].append(msg)
    module.debug = debug

    # Initialize variables
    api_url = module.params['api_url']
    auth_token = module.params['api_key']
    validate_certs = module.params['validate_certs']

    module.debug(f"Connecting to API URL: {api_url}")
    
    # Get current settings
    current_settings, error = get_system_general(module, api_url, auth_token, validate_certs)
    if error:
        module.fail_json(msg=f"Failed to get current settings: {error}")
    
    result['original_settings'] = current_settings
    
    # Define updates based on provided parameters
    updates = {}
    if module.params['domain'] is not None:
        if current_settings.get('domain') != module.params['domain']:
            updates['domain'] = module.params['domain']
            result['domain'] = module.params['domain']
    
    if module.params['hostname'] is not None:
        if current_settings.get('hostname') != module.params['hostname']:
            updates['hostname'] = module.params['hostname']
            result['hostname'] = module.params['hostname']
    
    if not updates:
        module.exit_json(**result)
    
    result['changed'] = True
    
    if module.check_mode:
        module.exit_json(**result)
    
    # Perform update
    updated_settings, error = update_system_general(module, api_url, auth_token, validate_certs, updates)
    if error:
        module.fail_json(msg=f"Failed to update settings: {error}")
    
    result['updated_settings'] = updated_settings
    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
