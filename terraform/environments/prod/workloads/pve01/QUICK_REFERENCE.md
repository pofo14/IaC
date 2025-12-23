# TrueNAS Files VM - Quick Reference

## Essential Information

| Item | Value |
|------|-------|
| **FQDN** | files.flopo.retropetro.net |
| **IP Address** | 10.10.20.10/24 |
| **VM ID** | (set by Terraform) |
| **Template ID** | 9001 |
| **Web UI** | <https://files.flopo.retropetro.net> |
| **SSH User** | truenas_admin |
| **Purpose** | Primary NAS for media, ROMs, backups |

## Resources

- **CPU:** 4 cores @ host passthrough
- **Memory:** 32GB RAM
- **Boot Disk:** 128GB
- **PCI Devices:** LSI SAS HBA (direct disk access)

## Quick Commands

```bash
# Deploy VM
terraform apply

# Destroy VM
terraform destroy

# View outputs
terraform output

# SSH to TrueNAS
ssh truenas_admin@files.flopo.retropetro.net

# Check ZFS pools
zpool list
zpool status

# Check ARC stats
arc_summary

# View disks
lsblk
smartctl -a /dev/sda
```

## Common Tasks

### Create ZFS Pool (via UI)

1. Storage → Create Pool
2. Select disks from HBA
3. Choose RAID level (RAIDZ1/RAIDZ2/Mirror)
4. Set pool name (e.g., "tank")
5. Apply

### Create NFS Share

1. Shares → Unix Shares (NFS) → Add
2. Path: /mnt/tank/media
3. Networks: 192.168.2.0/24
4. Enable service: Services → NFS → Start

### Create SMB Share

1. Shares → Windows Shares (SMB) → Add
2. Path: /mnt/tank/media
3. Name: media
4. Enable service: Services → SMB → Start

## Troubleshooting

### VM won't start

```bash
# Check PCI mapping
pvesh get /cluster/mapping/pci
```

### Can't see disks in TrueNAS

- Verify HBA is passed through
- Check HBA is in IT mode (not RAID)
- View console: `dmesg | grep sd`

### Slow performance

- Check ARC: `arc_summary`
- Verify CPU: Should be "host" type
- Test network: `iperf3`

## File Locations

- **Terraform:** `/workspaces/IaC/terraform/environments/prod/workloads/pve01/`
- **Ansible:** `/workspaces/IaC/ansible/roles/truenas/`
- **Packer:** `/workspaces/IaC/packer/modules/truenas/25.10/`

## Support

- **README:** [README.md](README.md)
- **Full Guide:** [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **Module Docs:** [/modules/vm-clone-bgp/](../../../../modules/vm-clone-bgp/)
