output "hub_vnet_id" {
  description = "Hub VNet resource ID"
  value       = module.networking.hub_vnet_id
}

output "spoke_prod_vnet_id" {
  description = "Production spoke VNet resource ID"
  value       = module.networking.spoke_prod_vnet_id
}

output "bastion_dns_name" {
  description = "Azure Bastion DNS name"
  value       = module.networking.bastion_dns_name
}

output "keyvault_name" {
  description = "Key Vault name"
  value       = module.keyvault.vault_name
}

output "linux_vm_private_ip" {
  description = "Private IP of the Linux VM"
  value       = module.compute.linux_vm_private_ip
}