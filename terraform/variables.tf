# ──────────────────────────────────────────────
# Global Variables
# ──────────────────────────────────────────────

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "southcentralus" # Closest to Louisiana — low latency
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project prefix for resource naming"
  type        = string
  default     = "cloudops"
}

variable "common_tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "CloudOps-Platform"
    ManagedBy   = "Terraform"
    Owner       = "YOUR_NAME"
    Environment = "dev"
  }
}

# ──────────────────────────────────────────────
# Network Variables
# ──────────────────────────────────────────────

variable "hub_vnet_address_space" {
  description = "Address space for the hub VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "spoke_prod_address_space" {
  description = "Address space for the production spoke VNet"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "spoke_dev_address_space" {
  description = "Address space for the development spoke VNet"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

# ──────────────────────────────────────────────
# Compute Variables
# ──────────────────────────────────────────────

variable "vm_admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "cloudopsadmin"
}

variable "vm_size_linux" {
  description = "VM size for Linux workloads"
  type        = string
  default     = "Standard_B1s" # Free tier eligible
}

variable "vm_size_windows" {
  description = "VM size for Windows workloads"
  type        = string
  default     = "Standard_B2s"
}