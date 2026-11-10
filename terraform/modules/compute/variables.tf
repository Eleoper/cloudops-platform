variable "location" {
  type = string
}

variable "project_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "app_subnet_id" {
  description = "Subnet ID for the app tier"
  type        = string
}

variable "vm_admin_username" {
  type = string
}

variable "vm_admin_password" {
  type      = string
  sensitive = true
}

variable "vm_size_linux" {
  type    = string
  default = "Standard_B1s"
}

variable "vm_size_windows" {
  type    = string
  default = "Standard_B2s"
}