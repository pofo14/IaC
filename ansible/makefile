test-nas:
	ansible-playbook site.yml -v -i ./inventories/staging --limit nas --ask-become-pass

prod-nas:
	ansible-playbook site.yml -v -i ./inventories/production --limit nas --ask-become-pass

test-nas-snapraid:
	ansible-playbook site.yml -v -i ./inventories/staging --limit nas --ask-become-pass --tags snapraid

test-plex:
	ansible-playbook site.yml -v -i ./inventories/staging --limit plex --ask-become-pass

prod-plex:
	ansible-playbook site.yml -v -i ./inventories/production --limit plex --ask-become-pass

prod-docker:
	ansible-playbook site.yml -v -i ./inventories/production --limit docker --ask-become-pass

prod-nextcloud:
	ansible-playbook site.yml -v -i ./inventories/production --limit nextcloud --ask-become-pass

prod-utils:
	ansible-playbook site.yml -v -i ./inventories/production --limit utils --ask-become-pass

prod-utils-tags:
	ansible-playbook site.yml -v -i ./inventories/production --limit utils --tags compose --ask-become-pass

prod-pihole:
	ansible-playbook site.yml -v -i ./inventories/production --limit pihole --ask-become-pass

prod-truenas:
	ansible-playbook site.yml -v -i ./inventories/production --limit truenas --ask-become-pass

prod-proxmox:
	ansible-playbook site.yml -v -i ./inventories/production --limit proxmox --ask-become-pass


########################## DEV PROXMOX CLUSTER ###################################
dev-pve01-install:
	ansible-playbook site.yml -v -i ./inventories/dev --limit dev-pve01.flopo.retropetro.net --extra-vars "pve_cluster_enabled=false"

dev-pve02-install:
	ansible-playbook site.yml -v -i ./inventories/dev --limit dev-pve02.flopo.retropetro.net --extra-vars "pve_cluster_enabled=false"

dev-pve-install:
	ansible-playbook site.yml -v -i ./inventories/dev --limit dev-pve

dev-pve-update:
	ansible-playbook site.yml -v -i ./inventories/dev --tags update_dev_pve
	@echo "Dev Proxmox cluster setup complete!"

########################## PRODUCTION PROXMOX CLUSTER ###################################
prod-pve1:
	ansible-playbook site.yml -v -i ./inventories/production --limit pve01.flopo.retropetro.net

prod-pve2:
	ansible-playbook site.yml -v -i ./inventories/production --limit pve02.flopo.retropetro.net

test-pve1:
	ansible-playbook site.yml -v -i ./inventories/test --limit pve1 --ask-become-pass

prod-management:
	ansible-playbook site.yml -v -i ./inventories/production --limit management

test-truenas:
	ansible-playbook site.yml -v -i ./inventories/test --limit test-truenas1.flopo.retropetro.net --ask-become-pass
### Vault Commands ####
check-vault:
	ansible-vault view inventories/production/group_vars/all/vault.yml

######### Utility Calls #######
# Manage ISOs for specific hosts
manage-isos-pve1:
	ansible-playbook -i ./inventories/production ./playbooks/manage_proxmox_isos.yml -e "target_hosts=pve1" --ask-become-pass

# Updates prometheus target json file
update_prometheus:
	ansible-playbook -i ./inventories/staging ./playbooks/update_prometheus_targets.yml --ask-become-pass

test-formatdisk-nas:
	ansible-playbook ./playbooks/format-disk.yml -i staging --limit nas --ask-become-pass

delete_pars:
	ansible-playbook ./playbooks/delete-partitions.yml -i staging --limit nas --ask-become-pass

fix-ssh-keys:
	ssh-keygen -f '/home/pofo14/.ssh/known_hosts' -R 'pve.flopo.retropetro.net'
	@echo "SSH host key removed. Now try running your ansible command again."

.PHONY: generate-preseed-dev
generate-preseed-dev:
	ansible-playbook -i ./inventories/dev playbooks/generate_preseed.yml -vvv

######## TEST CALLS ######
mount-disk-nas:
	ansible-playbook ./playbooks/mount-disks.yml -i staging --limit nas --ask-become-pass


##### Requirements #####
reqs:
	ansible-galaxy install -r requirements.yaml --roles-path /home/vscode/.ansible/roles
	ansible-galaxy collection install -r requirements.yaml --collections-path /home/vscode/.ansible/collections

forcereqs:
	ansible-galaxy install -r requirements.yaml --force


##### TERRAFORM COMMANDS ######
