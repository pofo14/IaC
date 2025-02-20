source "proxmox-iso" "opnsense" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_api_url
  node                     = var.proxmox_node
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true
  task_timeout        = "30m"

  # will need to install manually post-install
  qemu_agent = false

  # VM General Settings
  vm_name  = "opnsense-template"
  vm_id    = 9000
  template_description = "OPNsense Template"
  template_name          = "opnsense-template"
  memory   = 8192
  cores    = 2


  # ISO Settings
  boot_iso {
    #iso_url      = "https://mirrors.nycbug.org/pub/opnsense/releases/25.1/OPNsense-25.1-dvd-amd64.iso.bz2"
    iso_checksum = "68efe0e5c20bd5fbe42918f000685ec10a1756126e37ca28f187b2ad7e5889ca"
    iso_storage_pool = "local"
    iso_target_path = "OPNsense-25.1-dvd-amd64.iso"  # Remove 'local:iso/' prefix
    unmount     = true
     iso_urls = [
       "local:iso/OPNsense-25.1-dvd-amd64.iso",
       "https://mirrors.nycbug.org/pub/opnsense/releases/25.1/OPNsense-25.1-dvd-amd64.iso.bz2"
     ]
  }

  # Network Settings
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Disk Settings
  disks {
    type              = "scsi"
    disk_size         = "32G"
    storage_pool      = "local-zfs"
  }

  # HTTP Settings
  http_directory = "${path.root}/http"
  http_bind_address = "0.0.0.0" 
  http_port_min   = 8100
  http_port_max   = 8100

  boot_wait           = "90s"
  boot_command = [
    "installer<enter>",
    "<wait5>",
    "opnsense<enter>",
    "<wait10>",
    # Accept defaults for the following prompts
    "<enter><wait5>",  # Accept keyboard layout
    "<enter><wait5>",  # Accept ZFS filesystem
    "<enter><wait5>",  # Accept stripe
    "<spacebar><enter><wait5>",  # Accept ada0    
    "y",  # Accept ada0  , install
    "<wait220>",
    "<enter><wait5>",  # change root
    "${var.opnsense_root_password}<enter><wait5>",  # Set root password
    "${var.opnsense_root_password}<enter><wait5>",  # Confirm root password    
    "<wait30>",
    "c<enter><wait10>",  # Complete Install
    "r<enter><wait120>", # Reboot

    # login after reboot
    "root<enter>",
    "<wait5>",
    "${var.opnsense_root_password}<enter>",
    "<wait10>",    
    "2<enter><wait1>", # Set Interface IP Address
    "N<enter><wait1>", # No DHCP, Assign Static IP
    "192.168.2.49<enter><wait1>", # Assign Default IP on Correct Subnet
    "24<enter><wait1>", # Assign Default Subnet Mask
    "<enter><wait1>",
    "N<enter><wait1>", # No IPv6
    "<enter><wait1>", # None IPV6
    "y<enter><wait1>", # Enable DHCP
    "192.168.2.50<enter><wait1>", # Assign DHCP Start
    "192.168.2.255<enter><wait1>", # Assign DHCP End
    "N<enter><wait1>", # No http
    "N<enter><wait1>", # No self-signed
    "N<enter><wait1>", # No Load Defaults
    "<wait10>",
    "8<enter>",        # Enter shell
    "<wait1>",
    "service openssh onestart<enter>",  # Start SSH service
    "exit<enter>",  # Exit shell
    "5<enter>", # power off system
    "<wait30>"
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
  sources = ["source.proxmox-iso.opnsense"]

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

