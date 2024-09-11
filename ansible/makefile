test-nas:
	ansible-playbook site.yml -v -i ./inventories/staging --limit nas --ask-become-pass

test-nas-snapraid:
	ansible-playbook site.yml -v -i ./inventories/staging --limit nas --ask-become-pass --tags snapraid

test-plex:
	ansible-playbook site.yml -v -i ./inventories/staging --limit plex --ask-become-pass

######### Utility Calls #######
update_prometheus:
	ansible-playbook -i ./inventories/staging ./playbooks/update_prometheus_targets.yml --ask-become-pass

test-formatdisk-nas:
	ansible-playbook ./playbooks/format-disk.yml -i staging --limit nas --ask-become-pass

delete_pars:
	ansible-playbook ./playbooks/delete-partitions.yml -i staging --limit nas --ask-become-pass

######## TEST CALLS ######
mount-disk-nas:
	ansible-playbook ./playbooks/mount-disks.yml -i staging --limit nas --ask-become-pass


##### Requirements #####
reqs:
	ansible-galaxy install -r requirements.yaml

forcereqs:
	ansible-galaxy install -r requirements.yaml --force