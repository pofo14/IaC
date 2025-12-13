# How to find the interface names for each server

Boot each server with a live USB/installer, then run:

ip link show | grep -v lo | grep -E '^[0-9]+:' | awk -F': ' '{print $2}'
