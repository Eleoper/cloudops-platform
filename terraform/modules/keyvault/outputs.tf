output "vault_name" {
  value = azurerm_key_vault.main.name
}

output "vault_id" {
  value = azurerm_key_vault.main.id
}

output "vm_password" {
  value     = random_password.vm_password.result
  sensitive = true
}