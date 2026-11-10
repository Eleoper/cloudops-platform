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

variable "hub_address_space" {
  type = list(string)
}

variable "spoke_prod_address_space" {
  type = list(string)
}

variable "spoke_dev_address_space" {
  type = list(string)
}