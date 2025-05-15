#!/bin/bash
# /etc/rc.local doesn't run by default on SCALE, so use a one-time systemd service

mkdir -p /root/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFw3M5B7y0icwQpUO2NvYEqg1qckmd1j01YpAxhm+HM pofo14@pc-ken" > /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

systemctl enable ssh
systemctl start ssh

# Optionally enable QEMU guest agent too:
# systemctl enable qemu-guest-agent
# systemctl start qemu-guest-agent

# Clean up after first boot
rm -f /etc/systemd/system/enable-ssh.service
rm -f /root/enable-ssh.sh
