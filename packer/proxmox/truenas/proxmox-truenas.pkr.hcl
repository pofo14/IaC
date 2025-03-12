source "proxmox-iso" "truenas" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_api_url
  node                     = var.proxmox_node
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true
  task_timeout        = "30m"

  # will need to install manually post-installs
  qemu_agent = true

  # VM General Settings
  vm_name  = "Truenas-template"
  vm_id    = 9001
  template_description = "Truenas Template"
  template_name          = "Truenas-template"
  memory   = 8192
  cores    = 2


  # ISO Settings
  boot_iso {
    #iso_url      = "https://mirrors.nycbug.org/pub/opnsense/releases/25.1/OPNsense-25.1-dvd-amd64.iso.bz2"
    iso_checksum = "33e29ed62517bc5d4aed6c80b9134369e201bb143e13fefdec5dbf3820f4b946"
    iso_storage_pool = "local"
    iso_target_path = "TrueNAS-SCALE-24.10.2.iso"  # Remove 'local:iso/' prefix
    unmount     = true
    iso_file = "local:iso/TrueNAS-SCALE-24.10.2.iso"
    # iso_urls = [
   #    "local:iso/TrueNAS-SCALE-24.10.2.iso"# ,
     #  "https://download.sys.truenas.net/TrueNAS-SCALE-ElectricEel/24.10.2/TrueNAS-SCALE-24.10.2.iso"
   #  ]
  }

  # Network Settings
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Disk Settings
  disks {
    type              = "scsi"
    disk_size         = "16G"
    storage_pool      = "local-zfs"
  }

  # HTTP Settings
  http_directory = "${path.root}/http"
  http_bind_address = "0.0.0.0" 
  http_port_min   = 8100
  http_port_max   = 8100

  boot_wait           = "45s"
  boot_command = [
    "1<enter><wait5>",
    "<spacebar><wait3><enter>",
    "<enter><wait5>",
    # "1<enter><wait3>",
    "${var.opnsense_root_password}<tab><wait5>",  # Set root password
    "${var.opnsense_root_password}<wait5>",  # Confirm root password    
    "<enter>",
    "<enter>",
    "<wait100>"
  ]

  # SSH Settings
  
  communicator = "none"
  #ssh_private_key_file = "~/.ssh/id_ed25519"
  #ssh_username = "root"
  #ssh_host = "192.168.2.49"
  #ssh_password = var.opnsense_root_password
  #ssh_timeout  = "5m"
}

build {
  sources = ["source.proxmox-iso.truenas"]

  # provisioner "shell" {
  #   script          = "${path.root}/scripts/base.sh"
  #   execute_command = "chmod +x {{ .Path }}; /bin/sh -c '{{ .Vars }} {{ .Path }}'"
  # }
  # provisioner "shell" {
  #   inline = [
  #     "fetch -o /conf/config.xml http://{{ .HTTPIP }}:{{ .HTTPPort }}/config.xml",
  #     "/usr/local/etc/rc.reload_all"
  #   ]
  # }  
}

