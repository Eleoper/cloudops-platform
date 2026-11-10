# ══════════════════════════════════════════════
# LINUX VM — Ubuntu Application Server
# ══════════════════════════════════════════════

resource "azurerm_network_interface" "linux_vm" {
  name                = "nic-${var.project_name}-linux"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
    # No public IP — access only via Bastion
  }
}

resource "azurerm_linux_virtual_machine" "app" {
  name                            = "vm-${var.project_name}-linux"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size_linux
  admin_username                  = var.vm_admin_username
  admin_password                  = var.vm_admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.linux_vm.id]
  tags                            = var.tags

  priority        = "Regular"

  os_disk {
    name                 = "osdisk-linux"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Install Docker and Nginx on first boot
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io nginx
    systemctl enable docker
    systemctl start docker
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>CloudOps Linux VM - $(hostname)</h1>" > /var/www/html/index.html
  EOF
  )
}

# ══════════════════════════════════════════════
# WINDOWS VM — Simulated AD-Joined Workload
# ══════════════════════════════════════════════

resource "azurerm_network_interface" "windows_vm" {
  name                = "nic-${var.project_name}-windows"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "app" {
  name                = "vm-${var.project_name}-win"  # Max 15 chars for Windows
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size_windows
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  network_interface_ids = [azurerm_network_interface.windows_vm.id]
  tags                = var.tags

  priority        = "Spot"
  eviction_policy = "Deallocate"
  max_bid_price   = -1

  os_disk {
    name                 = "osdisk-windows"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
}

# ══════════════════════════════════════════════
# AUTO-SHUTDOWN (Cost Control)
# ══════════════════════════════════════════════

resource "azurerm_dev_test_global_vm_shutdown_schedule" "linux" {
  virtual_machine_id    = azurerm_linux_virtual_machine.app.id
  location              = var.location
  enabled               = true
  daily_recurrence_time = "2200"              # 10 PM
  timezone              = "Central Standard Time"  # Louisiana timezone

  notification_settings {
    enabled = false
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "windows" {
  virtual_machine_id    = azurerm_windows_virtual_machine.app.id
  location              = var.location
  enabled               = true
  daily_recurrence_time = "2200"
  timezone              = "Central Standard Time"

  notification_settings {
    enabled = false
  }
}