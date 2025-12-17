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

  tags = var.tags
}

# -------------------------
# Storage Container
# -------------------------
resource "azurerm_storage_container" "tfstate" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"

  depends_on = [
    azurerm_storage_account.sa
  ]
}

# -------------------------
/* My Subscription has restrictions that require this setup for GitHub Actions OIDC */

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
  subject  = "repo:YOUR_ORG/YOUR_REPO:ref:refs/heads/main"
  audiences = ["api://AzureADTokenExchange"]
}
*/

