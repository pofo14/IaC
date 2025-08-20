build-noble:
	packer build  -var-file='credentials.pkr.hcl' ./ubuntu-server-noble/ubuntu-server-noble.pkr.hcl

build-opnsense:
	packer build ./opnsense

valid-opnsense:
	packer validate ./opnsense

build-truenas24:
	packer build ./truenas-24.10

valid-truenas24:
	packer validate ./truenas-24.10

# Add SOPS decryption helper
decrypt-secrets:
	sops -d secrets.enc.yml > secrets.yml

build-truenas25: decrypt-secrets
	packer build ./truenas-25.04
	rm -f secrets.yml

valid-truenas25:
	packer validate ./truenas-25.04	