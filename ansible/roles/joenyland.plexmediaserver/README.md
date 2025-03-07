joenyland.plexmediaserver
=========================

[![CI](https://github.com/JoeNyland/ansible-plexmediaserver-role/actions/workflows/ci.yml/badge.svg)](https://github.com/JoeNyland/ansible-plexmediaserver-role/actions/workflows/ci.yml)

Installs [Plex Media Server](https://www.plex.tv/en-gb/media-server-downloads/).

Requirements
------------

None.

Role Variables
--------------


### `plexmediaserver_service_enabled`

Should the plexmediaserver service start at boot?


### `plexmediaserver_service_state`

What state should the plexmediaserver service be in? e.g. started/stopped


Dependencies
------------

None.

Example Playbook
----------------

```yaml
- hosts: server
  roles:
    - joenyland.plexmediaserver
```

License
-------

MIT

Author Information
------------------

⌨️ with ❤️ by [Joe Nyland](https://joe.nyland.io)
