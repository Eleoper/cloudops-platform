output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "spoke_prod_vnet_id" {
  value = azurerm_virtual_network.spoke_prod.id
}

output "spoke_dev_vnet_id" {
  value = azurerm_virtual_network.spoke_dev.id
}

output "spoke_prod_app_subnet_id" {
  value = azurerm_subnet.spoke_prod_app.id
}

output "spoke_prod_web_subnet_id" {
  value = azurerm_subnet.spoke_prod_web.id
}

output "spoke_prod_data_subnet_id" {
  value = azurerm_subnet.spoke_prod_data.id
}

output "spoke_dev_app_subnet_id" {
  value = azurerm_subnet.spoke_dev_app.id
}

output "bastion_dns_name" {
  value = azurerm_bastion_host.main.dns_name
}

output "hub_firewall_subnet_id" {
  value = azurerm_subnet.hub_firewall.id
}