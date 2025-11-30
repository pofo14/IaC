##############################################
# GLOBAL PACKER VARIABLES (auto-loaded)
# Non-secret, universal defaults
##############################################

# Default CPU / RAM profiles
cores  = 4
memory = 8192

# Default disk settings used by most builds
disk_storage = "zfs01"
disk_size_gb = 32

# Default network adapter bridge
network_bridge = "vmbr0"

# Default ISO storage pool (where ISOs live)
storage_pool_iso = "iso"

# Default storage pool for ZFS-backed disks
storage_pool_zfs = "zfs01"

# Default SCSI controller
scsi_controller = "virtio-scsi-single"

# Default boot wait time used across templates
boot_wait = "10s"

# Default boot key interval (safe, fast typing)
boot_key_interval = "10ms"

# Universal template naming prefix
template_name_prefix = "packer"

# In Packer 1.12+ an OS type is required (applies to most builds)
os_type = "other"
