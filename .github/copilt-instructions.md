# Project AI Rules
- Prefer Terraform 1.6+ syntax; run `terraform fmt` always.
- Use `for_each` vs `count`; keep modules idempotent.
- For Ansible: YAML 2-space indent; `block` + `rescue` for risky ops; no `shell` unless necessary.
- Use Terraform MCP server to read latest provider documentation
- Use bgp/promox provider for any terraform modules interacting with proxmox
- Prefer lae.proxmox role for any ansible playbooks/tasks that interact with proxmox
- Prefer arensb.truenas for any ansible playbooks/tasks that interact with truenas


## PR checklist
- Include `terraform plan` summary with risk notes.
- For Ansible: show `--check` dry-run output.


## Common prompts
- "Refactor this module to remove implicit depends_on."
- "Add Ansible task with retries/backoff and idempotency guard."



