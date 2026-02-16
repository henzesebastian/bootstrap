output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

# -------------------------
# Azure Subscription Information
# -------------------------
output "subscription_id" {
  description = "Azure Subscription ID for GitHub Actions"
  value       = "8aed33d3-48a3-48f1-b05c-87b8a109cabf"
}

# OIDC outputs commented out - using traditional service principal instead
/*
output "azure_client_id" {
  description = "Azure AD Application (Client) ID for GitHub Actions OIDC"
  value       = azuread_application.github_oidc_app.client_id
}

output "azure_tenant_id" {
  description = "Azure AD Tenant ID for GitHub Actions OIDC"
  value       = azuread_service_principal.github_oidc_sp.application_tenant_id
}

output "service_principal_object_id" {
  description = "Service Principal Object ID for role assignments"
  value       = azuread_service_principal.github_oidc_sp.object_id
}
*/