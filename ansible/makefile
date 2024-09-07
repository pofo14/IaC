test-nas:
	ansible-playbook site.yml -v -i staging --limit nas --ask-become-pass

test-formatdisk-nas:
	ansible-playbook ./playbooks/format-disk.yml -i staging --limit nas --ask-become-pass

delete_pars:
	ansible-playbook ./playbooks/delete-partitions.yml -i staging --limit nas --ask-become-pass

mount-disk-nas:
	ansible-playbook ./playbooks/mount-disks.yml -i staging --limit nas --ask-become-pass

reqs:
	ansible-galaxy install -r requirements.yaml

forcereqs:
	ansible-galaxy install -r requirements.yaml --force