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

  validation {
    condition = var.storage_account_name == "" || can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 lowercase letters or numbers, or left empty to auto-generate."
  }
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

# Commented out - only needed if deploying the order portal web app
# variable "github_token" {
#   description = "GitHub PAT with workflow permissions"
#   type        = string
#   sensitive   = true
# }
