output "linux_vm_private_ip" {
  value = azurerm_network_interface.linux_vm.private_ip_address
}

output "linux_vm_id" {
  value = azurerm_linux_virtual_machine.app.id
}

output "windows_vm_private_ip" {
  value = azurerm_network_interface.windows_vm.private_ip_address
}

output "windows_vm_id" {
  value = azurerm_windows_virtual_machine.app.id
}