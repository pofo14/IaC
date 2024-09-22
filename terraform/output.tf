# output IP Address
output "vm_ip" {
  value = proxmox_vm_qemu.vm_factory.*.default_ipv4_address
}