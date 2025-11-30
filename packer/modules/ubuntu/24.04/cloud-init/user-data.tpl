#cloud-config
autoinstall:
  version: 1

  locale: en_US
  keyboard:
    layout: us

  identity:
    hostname: ubuntu-template
    username: ${username}
    password: "${password_hash}"

  ssh:
    install-server: true
    authorized-keys:
%{ for key in ssh_keys ~}
      - "${key}"
%{ endfor ~}
    allow-pw: false

  storage:
    layout:
      name: direct

  packages:
    - qemu-guest-agent
    - cloud-init

  late-commands:
    - curtin in-target --target=/target -- systemctl enable qemu-guest-agent
    - curtin in-target --target=/target -- systemctl enable ssh
    # Set timezone
    - curtin in-target --target=/target -- timedatectl set-timezone America/New_York
    # Add user to sudo group and configure NOPASSWD
    - sh -c "printf '%s\n' '${username} ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/${username} && chmod 0440 /target/etc/sudoers.d/${username}"

# Post-installation cloud-init configuration (runs on first boot after install)
  # user-data:
  #   users:
  #     - name: pofo14
  #       gecos: pofo14
  #       groups: [sudo, adm]
  #       shell: /bin/bash
  #       sudo: ["ALL=(ALL) NOPASSWD:ALL"]
  #       lock_passwd: false

package_upgrade: true
