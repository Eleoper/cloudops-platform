# ──────────────────────────────────────────────
# Resource Groups
# ──────────────────────────────────────────────

resource "azurerm_resource_group" "network" {
  name     = "rg-${var.project_name}-network"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_resource_group" "compute" {
  name     = "rg-${var.project_name}-compute"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_resource_group" "security" {
  name     = "rg-${var.project_name}-security"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_resource_group" "devops" {
  name     = "rg-${var.project_name}-devops"
  location = var.location
  tags     = var.common_tags
}

# ──────────────────────────────────────────────
# Networking Module
# ──────────────────────────────────────────────

module "networking" {
  source = "./modules/networking"

  location            = var.location
  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.common_tags

  hub_address_space        = var.hub_vnet_address_space
  spoke_prod_address_space = var.spoke_prod_address_space
  spoke_dev_address_space  = var.spoke_dev_address_space
}

# ──────────────────────────────────────────────
# Key Vault Module
# ──────────────────────────────────────────────

module "keyvault" {
  source = "./modules/keyvault"

  location            = var.location
  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.security.name
  tags                = var.common_tags
}

# ──────────────────────────────────────────────
# Compute Module
# ──────────────────────────────────────────────

module "compute" {
  source = "./modules/compute"

  location            = var.location
  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.compute.name
  tags                = var.common_tags

  app_subnet_id     = module.networking.spoke_prod_app_subnet_id
  vm_admin_username = var.vm_admin_username
  vm_admin_password = module.keyvault.vm_password
  vm_size_linux     = var.vm_size_linux
  vm_size_windows   = var.vm_size_windows
}