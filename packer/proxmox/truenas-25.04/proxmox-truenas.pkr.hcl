source "proxmox-iso" "truenas-25" {
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
  vm_name  = "truenas-25"
  vm_id    = 9002
  template_description = "Truenas 25.04 Template"
  template_name          = "Truenas-25.04-template"
  memory   = 8192
  cores    = 2


  # ISO Settings
  boot_iso {
    #iso_url      = "https://mirrors.nycbug.org/pub/opnsense/releases/25.1/OPNsense-25.1-dvd-amd64.iso.bz2"
    iso_checksum = "ede23d4c70a7fde6674879346c1307517be9854dc79f6a5e016814226457f359"
    iso_storage_pool = "local"
    iso_target_path = "TrueNAS-SCALE-25.04.0.iso"  # Remove 'local:iso/' prefix
    unmount     = true
    iso_file = "local:iso/TrueNAS-SCALE-25.04.0.iso"
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
    "<spacebar><wait3><enter><wait5>",
    "y<wait5>",
    "1<wait2><enter><wait5>",
    "${var.truenas_root_password}<tab><wait5>",  # Set root password
    "${var.truenas_root_password}<wait5>",  # Confirm root password    
    "<enter><wait3>", 
    # Yes (default for EFI Boot)
    "<enter><wait3>",
    # Wait for installation to complete
    "<wait150>",

    # Installation complete, select OK
    "<enter><wait3>",

    # After install, Select reboot (Option 3)
    "<wait10>",
    "3<wait2><enter><wait5>",
    "<wait150>",

    # Enter Truenas CLI (Option 7) ** Changed from v24.10.2
    "7<wait3><enter><wait15>",
    #Enable SSH
    "service update id_or_name=ssh enable=true<wait3><enter><wait7>",
    "service start service=ssh<wait3><enter><wait7>q<wait3>",
    "service ssh update password_login_groups=truenas_admin<wait5><enter><wait5>",
    "quit<enter><wait20>",
    # Shutdown
    "10<wait3><enter><wait3>image build<enter><wait5>"
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
  sources = ["source.proxmox-iso.truenas-25"]

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

