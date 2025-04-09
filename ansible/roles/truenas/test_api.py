#!/usr/bin/env python3
import websocket
import json
import ssl
import sys
import os

# Configuration
CONFIG = {
    "host": "192.168.2.147",
    "port": 80,
    "api_key": os.getenv("TRUENAS_API_KEY", "your-api-key-here"),
}

def print_response(title, response):
    print(f"\n=== {title} ===")
    print(json.dumps(response, indent=2))
    print("=" * (len(title) + 8))

def main():
    # Create WebSocket connection
    ws_url = f"ws://{CONFIG['host']}:{CONFIG['port']}/websocket"
    print(f"Connecting to: {ws_url}")
    
    ws = websocket.create_connection(
        ws_url,
        sslopt={"cert_reqs": ssl.CERT_NONE}
    )

    try:
        # 1. Connect
        connect_msg = {
            "id": "1",
            "msg": "connect",
            "version": "1",
            "support": ["1"]
        }
        print("\nSending connect message...")
        ws.send(json.dumps(connect_msg))
        print_response("Connect Response", json.loads(ws.recv()))

        # 2. Authenticate
        auth_msg = {
            "id": "2",
            "msg": "method",
            "method": "auth.login_with_api_key",
            "params": [CONFIG["api_key"]]
        }
        print("\nSending auth message...")
        ws.send(json.dumps(auth_msg))
        print_response("Auth Response", json.loads(ws.recv()))

        # 3. Get current config
        config_msg = {
            "id": "3",
            "msg": "method",
            "method": "system.general.config",
            "params": []
        }
        print("\nGetting current config...")
        ws.send(json.dumps(config_msg))
        config_response = json.loads(ws.recv())
        print_response("Config Response", config_response)

        if "result" not in config_response:
            print(f"Error getting config: {config_response}")
            return

        # 4. Try update (if hostname provided)
        if len(sys.argv) > 1:
            new_hostname = sys.argv[1]
            # Use the current config and update just the hostname
            update_data = config_response["result"]
            update_data["hostname"] = new_hostname
            
            update_msg = {
                "id": "4",
                "msg": "method",
                "method": "system.general.update",
                "params": [update_data]
            }
            print(f"\nTrying to update hostname to: {new_hostname}")
            print("Using update message:", json.dumps(update_msg, indent=2))
            ws.send(json.dumps(update_msg))
            update_response = json.loads(ws.recv())
            print_response("Update Response", update_response)
            
            if "result" in update_response:
                print("Update successful!")
            elif "error" in update_response:
                print(f"Update failed: {update_response['error']}")
            else:
                print(f"Unexpected update response: {update_response}")

    finally:
        ws.close()

if __name__ == "__main__":
    # First make sure websocket-client is installed
    try:
        import websocket
    except ImportError:
        print("Please install websocket-client: pip install websocket-client")
        sys.exit(1)

    # Run the test
    main()
