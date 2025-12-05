variable "resource_group_name" {
  description = "Name of the Resource Group to create"
  type        = string
}

variable "resource_group_location" {
  description = "Azure region for the Resource Group"
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "Name of the Storage Account for Terraform state"
  type        = string
}

variable "container_name" {
  description = "Name of the blob container for Terraform state"
  type        = string
  default     = "tfstate"
}
