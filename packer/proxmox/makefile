build-noble:
	packer build  -var-file='credentials.pkr.hcl' ./ubuntu-server-noble/ubuntu-server-noble.pkr.hcl

build-opnsense:
	packer build -var-file=./opnsense/credentials.json ./opnsense/opnsense-proxmox.json

valid-opnsense:
	packer validate -var-file=./opnsense/credentials.json ./opnsense/opnsense-proxmox.json
