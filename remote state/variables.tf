variable "resource_group_name" {
  type        = string
  description = "Resource Group for the TF state resources"
  default     = "rg-infrastruktur"
}

variable "resource_group_location" {
  type        = string
  description = "Azure region where resources should be deployed"
  default     = "Norway East"
}

variable "storage_account_name" {
  type        = string
  default     = ""
  description = "Optional custom storage account name. Leave empty to auto-generate tfstateXXXXXX."
}

variable "container_name" {
  type        = string
  default     = "tfstate"
  description = "Name of the storage container for Terraform state"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Optional resource tags"
}
