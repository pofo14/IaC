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

prod-pve1:
	ansible-playbook site.yml -v -i ./inventories/production --limit pve1 --ask-become-pass

test-pve1:
	ansible-playbook site.yml -v -i ./inventories/test --limit pve1 --ask-become-pass

prod-management:
	ansible-playbook site.yml -v -i ./inventories/production --limit management --ask-become-pass

test-truenas:
	ansible-playbook site.yml -v -i ./inventories/test --limit truenas --ask-become-pass
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

######## TEST CALLS ######
mount-disk-nas:
	ansible-playbook ./playbooks/mount-disks.yml -i staging --limit nas --ask-become-pass


##### Requirements #####
reqs:
	ansible-galaxy install -r requirements.yaml

forcereqs:
	ansible-galaxy install -r requirements.yaml --force


##### TERRAFORM COMMANDS ######
