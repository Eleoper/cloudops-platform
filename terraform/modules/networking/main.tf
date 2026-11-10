# ══════════════════════════════════════════════
# HUB VNET
# ══════════════════════════════════════════════

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${var.project_name}-hub"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.hub_address_space
  tags                = var.tags
}

# Hub Subnets
resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"  # Must be this exact name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/26"]        # /26 minimum for Firewall
}

resource "azurerm_subnet" "hub_bastion" {
  name                 = "AzureBastionSubnet"   # Must be this exact name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/26"]        # /26 minimum for Bastion
}

resource "azurerm_subnet" "hub_gateway" {
  name                 = "GatewaySubnet"        # Must be this exact name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.3.0/27"]        # For VPN Gateway (Phase 4)
}

resource "azurerm_subnet" "hub_management" {
  name                 = "snet-hub-management"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.4.0/24"]
}

# ══════════════════════════════════════════════
# SPOKE PROD VNET
# ══════════════════════════════════════════════

resource "azurerm_virtual_network" "spoke_prod" {
  name                = "vnet-${var.project_name}-spoke-prod"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.spoke_prod_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "spoke_prod_web" {
  name                 = "snet-prod-web"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke_prod.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "spoke_prod_app" {
  name                 = "snet-prod-app"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke_prod.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_subnet" "spoke_prod_data" {
  name                 = "snet-prod-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke_prod.name
  address_prefixes     = ["10.1.3.0/24"]
}

# ══════════════════════════════════════════════
# SPOKE DEV VNET
# ══════════════════════════════════════════════

resource "azurerm_virtual_network" "spoke_dev" {
  name                = "vnet-${var.project_name}-spoke-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.spoke_dev_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "spoke_dev_app" {
  name                 = "snet-dev-app"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke_dev.name
  address_prefixes     = ["10.2.1.0/24"]
}

# ══════════════════════════════════════════════
# VNET PEERINGS
# ══════════════════════════════════════════════

# Hub → Spoke Prod
resource "azurerm_virtual_network_peering" "hub_to_spoke_prod" {
  name                         = "peer-hub-to-spoke-prod"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_prod.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true   # Hub can share its gateway
  allow_virtual_network_access = true
}

# Spoke Prod → Hub
resource "azurerm_virtual_network_peering" "spoke_prod_to_hub" {
  name                         = "peer-spoke-prod-to-hub"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.spoke_prod.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true
  use_remote_gateways          = false  # Set to true after VPN Gateway deploy
  allow_virtual_network_access = true
}

# Hub → Spoke Dev
resource "azurerm_virtual_network_peering" "hub_to_spoke_dev" {
  name                         = "peer-hub-to-spoke-dev"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_dev.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  allow_virtual_network_access = true
}

# Spoke Dev → Hub
resource "azurerm_virtual_network_peering" "spoke_dev_to_hub" {
  name                         = "peer-spoke-dev-to-hub"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.spoke_dev.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true
  use_remote_gateways          = false
  allow_virtual_network_access = true
}

# ══════════════════════════════════════════════
# NETWORK SECURITY GROUPS
# ══════════════════════════════════════════════

# --- Prod Web Tier NSG ---
resource "azurerm_network_security_group" "prod_web" {
  name                = "nsg-prod-web"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP-Inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# --- Prod App Tier NSG ---
resource "azurerm_network_security_group" "prod_app" {
  name                = "nsg-prod-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "Allow-From-Web-Tier"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "443"]
    source_address_prefix      = "10.1.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH-From-Hub"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-RDP-From-Hub"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# --- Prod Data Tier NSG ---
resource "azurerm_network_security_group" "prod_data" {
  name                = "nsg-prod-data"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "Allow-SQL-From-App-Tier"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "10.1.2.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# --- Associate NSGs to Subnets ---
resource "azurerm_subnet_network_security_group_association" "prod_web" {
  subnet_id                 = azurerm_subnet.spoke_prod_web.id
  network_security_group_id = azurerm_network_security_group.prod_web.id
}

resource "azurerm_subnet_network_security_group_association" "prod_app" {
  subnet_id                 = azurerm_subnet.spoke_prod_app.id
  network_security_group_id = azurerm_network_security_group.prod_app.id
}

resource "azurerm_subnet_network_security_group_association" "prod_data" {
  subnet_id                 = azurerm_subnet.spoke_prod_data.id
  network_security_group_id = azurerm_network_security_group.prod_data.id
}

# ══════════════════════════════════════════════
# ROUTE TABLE (Force Spoke Traffic Through Hub)
# ══════════════════════════════════════════════

resource "azurerm_route_table" "spoke_prod" {
  name                          = "rt-spoke-prod"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = var.tags
  bgp_route_propagation_enabled = true

  route {
    name                   = "to-internet-via-hub"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.1.4"  # Azure Firewall private IP (assigned later)
  }

  route {
    name                   = "to-spoke-dev-via-hub"
    address_prefix         = "10.2.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.1.4"
  }
}

### Associate route table with spoke prod subnets
###resource "azurerm_subnet_route_table_association" "prod_web" {
###  subnet_id      = azurerm_subnet.spoke_prod_web.id
###  route_table_id = azurerm_route_table.spoke_prod.id
###}


###resource "azurerm_subnet_route_table_association" "prod_app" {
###  subnet_id      = azurerm_subnet.spoke_prod_app.id
###  route_table_id = azurerm_route_table.spoke_prod.id
###}

# ══════════════════════════════════════════════
# AZURE BASTION (Secure VM Access)
# ══════════════════════════════════════════════

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "main" {
  name                = "bas-${var.project_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  sku                 = "Basic"

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = azurerm_subnet.hub_bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}