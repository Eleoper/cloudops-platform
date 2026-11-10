terraform {
  backend "azurerm" {
    resource_group_name  = "rg-cloudops-tfstate"
    storage_account_name = "stcloudopstf2026x"
    container_name       = "tfstate"
    key                  = "cloudops.tfstate"
  }
}