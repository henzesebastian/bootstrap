# Copilot Instructions for Bootstrap Repository

## Project Purpose
This Terraform project provisions Azure infrastructure for remote state management, enabling distributed teams to safely manage Terraform state files in Azure Blob Storage with GitHub Actions integration support.

## Architecture Overview

### Core Components
- **Resource Group** (`azurerm_resource_group`): Container for all Azure resources, configured with default location "Norway East" and custom tags
- **Storage Account** (`azurerm_storage_account`): Standard LRS storage for Terraform state files with strict security settings
- **Storage Container** (`azurerm_storage_container`): Private container within the storage account that holds `.tfstate` files

### Key Security Patterns
1. **TLS 1.2 Minimum**: All connections enforced via `min_tls_version = "TLS1_2"`
2. **Public Access Enabled**: Despite strong security, `public_network_access_enabled = true` is REQUIRED for GitHub Actions CI/CD workflows to authenticate
3. **HTTPS Only**: `https_traffic_only_enabled = true` ensures encrypted state file access
4. **Private Container**: `container_access_type = "private"` prevents anonymous access to state data
5. **Blob Public Access Disabled**: `allow_nested_items_to_be_public = false` prevents individual state files from becoming public

### Naming Convention
- **Storage Account Name**: Uses pattern `tfstate{random_suffix}` where suffix is 6 lowercase alphanumeric characters, or custom name via `var.storage_account_name`
- **Resource Group**: Default name is `rg-infrastruktur`
- **Container Name**: Default is `tfstate`

## Critical Configuration Details

### Provider Configuration
- **Subscription ID**: Hardcoded to `8aed33d3-48a3-48f1-b05c-87b8a109cabf` (verify this is intentional for production)
- **Terraform Version**: Requires >= 1.3.0
- **AzureRM Provider**: Requires >= 3.0.0
- **Azure AD Provider**: Included but only used for commented OIDC federation setup

### GitHub Actions Integration Notes
The `public_network_access_enabled = true` setting is specifically documented as "REQUIRED for GitHub Actions" because:
- GitHub Actions runners may not have static IPs for firewall rules
- This requires strong authentication/authorization (handled via Azure storage account access keys or managed identities)
- Never rely solely on network isolation for state file security

### Commented OIDC Federation Setup
A federated identity credential configuration is commented out for optional Azure AD + GitHub Actions OIDC integration. This provides token-based authentication without storing credentials. The commented code shows the pattern needed when subscription restrictions require this setup.

## Development Workflow

### Typical Commands
```bash
cd "remote state"
terraform init       # Initialize Terraform working directory
terraform plan       # Preview infrastructure changes
terraform apply      # Apply configuration changes
terraform destroy    # Remove all resources (use with caution)
```

### Variable Customization
Override defaults using `terraform.tfvars` or command-line flags:
```bash
terraform apply -var="resource_group_location=West Europe" -var="tags={environment=prod}"
```

### State File Location
After deployment, the Terraform state file itself is stored in:
`Azure Storage Account > tfstate Container > terraform.tfstate`

This bootstrap Terraform state typically remains local (`.tfstate` file in the directory) until migrated to the created storage account.

## Code Conventions

1. **Resource Organization**: Resources grouped by function with markdown section headers (`# -------------------------`)
2. **Local Values**: Dynamic resource naming via `locals` block with ternary operators for conditional defaults
3. **Dependencies**: Explicit `depends_on` used sparingly; rely on implicit dependencies when possible
4. **Comments**: Code includes inline comments for non-obvious requirements (e.g., GitHub Actions requirement)
5. **Tags**: All resources respect `var.tags` for consistent organizational tagging

## When Adding New Azure Resources

1. **Always include `var.tags`** in resource blocks for consistency
2. **Respect security defaults**: Use TLS 1.2+, HTTPS-only where applicable
3. **Document "why" not "what"**: Add comments for subscription restrictions or integration requirements
4. **Use locals for derived values**: Complex naming logic belongs in `locals`, not hardcoded strings
5. **Export outputs**: Add corresponding entries to `outputs.tf` for all created resources
6. **Consider state backend**: If adding resources, update documentation about where terraform state is stored

## Common Patterns to Avoid

- **Don't hardcode subscription IDs** in new deployments (current code needs review on this)
- **Don't set `public_network_access_enabled = false`** unless you have static IP ranges for all CI/CD runners
- **Don't skip tags** - they're required for compliance and cost tracking
- **Don't use `Destroy` resource attribute** on storage accounts with state files (prevents accidental data loss)

## References
- [Azure Storage Terraform Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
- [GitHub Actions OIDC with Azure](https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation)
