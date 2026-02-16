resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = var.tags
}

# -------------------------
# Random suffix for storage
# -------------------------
resource "random_string" "sa_suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  storage_account_name = (
    var.storage_account_name != "" ?
    var.storage_account_name :
    "tfstate${random_string.sa_suffix.result}"
  )
}

# -------------------------
# Storage Account
# -------------------------
resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled      = true
  public_network_access_enabled   = true     # <-- REQUIRED for GitHub Actions
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

# -----------------------------------------#
# Storage Container for TF State          #
# -----------------------------------------#
resource "azurerm_storage_container" "tfstate" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

/*
###############################################
# Orderportal for Azure Resource Deployment   #
###############################################

resource "azurerm_resource_group" "web" {
  name     = "rg-order-portal"
  location = "Norway East"
}

resource "azurerm_service_plan" "plan" {
  name                = "asp-order-portal"
  location            = azurerm_resource_group.web.location
  resource_group_name = azurerm_resource_group.web.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "order-portal-demo-12345"
  location            = azurerm_resource_group.web.location
  resource_group_name = azurerm_resource_group.web.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }

  app_settings = {
    GITHUB_TOKEN = var.github_token
    GITHUB_OWNER = "your-org"
    GITHUB_REPO  = "terraform-services"
    WORKFLOW_ID  = "order.yml"
  }
}
*/









# -------------------------
# GitHub Actions Authentication
# -------------------------
# Using traditional Service Principal with Client Secret
# Requires Azure AD admin permissions - commented out for manual creation
#
# To create manually, run:
# az ad sp create-for-rbac --name "github-actions-terraform-course" \
#   --role "Contributor" \
#   --scopes /subscriptions/8aed33d3-48a3-48f1-b05c-87b8a109cabf \
#   --sdk-auth
#
# Save the output JSON and add to GitHub Secrets as AZURE_CREDENTIALS

# Uncomment below if you have Azure AD Application Administrator permissions:
/*
## Azure AD Application
resource "azuread_application" "github_oidc_app" {
  display_name = "github-actions-oidc-app"
}

# Service Principal
resource "azuread_service_principal" "github_oidc_sp" {
  client_id = azuread_application.github_oidc_app.client_id
}

# Federated Identity Credential for GitHub Actions OIDC
resource "azuread_application_federated_identity_credential" "github_oidc_federation" {
  application_id = azuread_application.github_oidc_app.id
  display_name   = "github-actions-federation"

  issuer   = "https://token.actions.githubusercontent.com"
  subject  = "repo:henzesebastian/terraform-course:ref:refs/heads/main"
  audiences = ["api://AzureADTokenExchange"]
}

# Role Assignment - Grant permissions to manage Terraform state
resource "azurerm_role_assignment" "github_sp_storage" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.github_oidc_sp.object_id
}

# Optional: Grant Contributor role at resource group level for broader permissions
resource "azurerm_role_assignment" "github_sp_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_oidc_sp.object_id
}
*/

