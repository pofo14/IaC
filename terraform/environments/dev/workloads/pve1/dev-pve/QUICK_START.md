# Quick Start: Test Preseed VM

## What You Have Now

✅ **Blank VM with predictable disk IDs**

- VM Name: `test-preseed`
- MAC Address: `BC:24:11:21:57:B7`
- SCSI Disks: `scsi0`, `scsi1` (40GB each)
- Boot: Stopped (ready for ISO/PXE)

✅ **Terraform Outputs**

```bash
mac_address         = "BC:24:11:21:57:B7"
ipxe_menu_filename  = "mac-bc-24-11-21-57-b7.ipxe"
expected_disk_paths = ["scsi-0QEMU_QEMU_HARDDISK_drive-scsi0", "scsi-0QEMU_QEMU_HARDDISK_drive-scsi1"]
```

## Next Steps

### Option 1: ISO Boot with Preseed (Quick Test)

**1. Download Debian ISO**

```bash
ssh root@pve1.flopo.retropetro.net
cd /var/lib/vz/template/iso
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.8.0-amd64-netinst.iso
```

**2. Attach ISO to VM**

```bash
qm set 109 --ide2 local:iso/debian-12.8.0-amd64-netinst.iso,media=cdrom
```

**3. Start VM and Boot**

- Open console in Proxmox UI
- At boot prompt, press `ESC`
- Type: `auto url=http://192.168.2.7/preseed/test-preseed.cfg`

---

### Option 2: PXE Boot (Production-Ready)

**1. Create iPXE Boot File**

```bash
# On management VM (192.168.2.7)
cat > /var/www/html/ipxe/mac-bc-24-11-21-57-b7.ipxe << 'IPXE'
#!ipxe
echo ========================================
echo Automated Debian Preseed Installation
echo Target: test-preseed
echo MAC: BC:24:11:21:57:B7
echo ========================================

kernel http://ftp.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux
initrd http://ftp.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz
imgargs linux auto=true priority=critical url=http://192.168.2.7/preseed/test-preseed.cfg interface=auto hostname=test-preseed domain=flopo.retropetro.net
boot
IPXE
```

**2. Configure VM for Network Boot**

```bash
ssh root@pve1.flopo.retropetro.net
qm set 109 --boot order=net0
```

**3. Start VM**

```bash
qm start 109
# Watch console - it will automatically boot from network
```

---

## Monitoring Installation

**Console Access:**

- Proxmox UI: Select VM → Console
- CLI: `qm terminal 109`

**Expected Behavior:**

1. VM boots (ISO or PXE)
2. Debian installer loads
3. Preseed file auto-configures:
   - Network (192.168.2.99/24)
   - Hostname (test-preseed)
   - Disk partitioning (ZFS mirror on scsi0/scsi1)
   - Packages and users
4. Automatic reboot after installation

---

## Troubleshooting

### Check Preseed File

```bash
curl http://192.168.2.7/preseed/test-preseed.cfg
# Should contain:
# - storage_disks references
# - Network configuration
# - ZFS setup
```

### Check iPXE File

```bash
curl http://192.168.2.7/ipxe/mac-bc-24-11-21-57-b7.ipxe
```

### VM Not Booting from Network?

```bash
# Verify boot order
qm config 109 | grep boot
# Should show: boot: order=net0

# Check network device
qm config 109 | grep net0
# Should show: net0: virtio=BC:24:11:21:57:B7,bridge=vmbr0
```

### Preseed Not Loading?

- Check VM can reach 192.168.2.7
- Verify preseed file exists and is readable
- Check Debian installer logs (Alt+F4 in console)

---

## After Successful Installation

**1. Verify Installation**

```bash
ssh pofo14@192.168.2.99
# Check ZFS pool
zpool status
# Check hostname
hostname
```

**2. Document Results**
Update your notes with any preseed adjustments needed

**3. Cleanup and Iterate**

```bash
# If you need to test again
terraform destroy
terraform apply
# Recreate iPXE file (MAC will change)
```

---

## Automation Path Forward

Once validated, create Ansible playbook:

```yaml
# ansible/playbooks/deploy_preseed_infrastructure.yml
- hosts: proxmox_hosts
  tasks:
    # 1. Generate preseed file
    # 2. Get MAC from Terraform output
    # 3. Generate iPXE file
    # 4. All ready for automated PXE boot
```

See `IPXE_BOOT_STRATEGY.md` for full automation details.
