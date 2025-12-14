# Packer IaC Template Build System

This repository manages automated VM template builds for:

- TrueNAS SCALE
- OPNsense
- Ubuntu Server
- (Additional OS builders can be added easily)

The goal is to provide a modular, production-grade structure that is:

- Consistent
- Environment-aware (prod/test/dev)
- Version-aware (different OS release versions)
- Reusable (modules shared across builders)
- Maintainable and scalable
- Compatible with Proxmox Packer plugin

---

## Project Structure

packer/
├── README.md
├── Makefile
├── helpers.mk
├── .gitignore
├── devcontainer/
│   ├── devcontainer.json
│   └── Dockerfile
├── plugins/
│   └── README.md
├── modules/
│   ├── common/
│   │   └── vm_common.pkr.hcl
│   ├── truenas/
│   │   ├── truenas_base.pkr.hcl
│   │   ├── versions/
│   │   │   ├── 25.04.pkrvars.hcl
│   │   │   └── 24.10.pkrvars.hcl
│   │   └── truenas-autoinstall/
│   │       └── grub.cfg
│   ├── opnsense/
│   │   ├── opnsense_base.pkr.hcl
│   │   ├── versions/
│   │   │   ├── 25.1.pkrvars.hcl
│   │   │   └── 24.7.pkrvars.hcl
│   │   └── installer/
│   │       └── config.xml
├── builds/
│   ├── truenas.pkr.hcl
│   ├── opnsense.pkr.hcl
│   └── ubuntu.pkr.hcl
└── variables/
    ├── global.auto.pkrvars.hcl
    ├── pve_prod.pkrvars.hcl
    ├── pve_test.pkrvars.hcl
    └── secrets.pkrvars.hcl (gitignored)

---

## How to Build an Image

Every build uses:

- 1 OS version vars file
- 1 environment vars file
- 1 global vars file
- CLI args for VMID, ENV, NODE

### Build TrueNAS

make truenas VERSION=25.04 ENV=prod NODE=pve01 VMID=9001

### Build OPNsense

make opnsense VERSION=25.7 ENV=prod NODE=pve01 VMID=9002

### Build Ubuntu

make ubuntu VERSION=24.04 ENV=prod NODE=pve01 VMID=9003

---

## Validate and Debug

Inspect a template:

make debug-vars

Validate:

packer validate builds/truenas.pkr.hcl

---

## Environment Variable Files

### variables/global.auto.pkrvars.hcl

proxmox_api_url = "<https://pve.example.com:8006/api2/json>"
template_name_prefix = "packer"
network_bridge = "vmbr0"

### variables/pve_prod.pkrvars.hcl

storage_pool_iso = "iso"
storage_pool_zfs = "zfs01"

### variables/pve_test.pkrvars.hcl

storage_pool_iso = "iso"
storage_pool_zfs = "test-zfs"

### variables/secrets.pkrvars.hcl (gitignored)

proxmox_api_token_id = "user@pam!token"
proxmox_api_token_secret = "YOUR_SECRET"

---

## Modular Design

Each OS has:

- Base module (builder + common config)
- Version files under modules/\<os\>/versions/
- Autoinstall or bootloader configs if needed

Example:

modules/truenas/
├── truenas_base.pkr.hcl
└── versions/
    └── 25.04.pkrvars.hcl

Supports:

make truenas VERSION=24.10 …
make truenas VERSION=25.04 …

---

## Makefile Commands

make truenas VERSION=X ENV=Y NODE=Z VMID=A
make opnsense VERSION=X ENV=Y NODE=Z VMID=A
make ubuntu VERSION=X ENV=Y NODE=Z VMID=A

Debug:

make debug-vars

---

## Dev Container Support

.devcontainer/ ensures:

- Correct Packer installation
- Correct plugin installation
- Stable, reproducible builds

---

## Plugin Management

Plugins stored under:

~/.config/packer/plugins/

---

## Adding a New OS

1. mkdir modules/\<os\>/
2. Add base: \<os\>_base.pkr.hcl
3. Add versions: modules/\<os\>/versions/\<version\>.pkrvars.hcl
4. Add builds/\<os\>.pkr.hcl
5. Add Makefile entry
6. Build:

make \<os\> VERSION=X ENV=prod NODE=pve1 VMID=900X

---

## License

Internal project.

---

## Support

Ping ChatGPT for CI/CD, Terraform Proxmox automation, HA cloning, etc.
