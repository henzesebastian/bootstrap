# GitHub Actions Service Principal Setup

Since you don't have Azure AD admin permissions, use this traditional service principal approach with client secret authentication.

## Step 1: Create Service Principal

Run this command to create a service principal with the necessary permissions:

```bash
az ad sp create-for-rbac --name "github-actions-terraform-course" \
  --role "Contributor" \
  --scopes /subscriptions/8aed33d3-48a3-48f1-b05c-87b8a109cabf \
  --sdk-auth
```

This will output JSON like:
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "8aed33d3-48a3-48f1-b05c-87b8a109cabf",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

**IMPORTANT**: Save this entire JSON output securely - you won't be able to retrieve the client secret again.

## Step 2: Grant Storage Access (if needed for Terraform state)

After running `terraform apply` in this bootstrap repo, grant the service principal access to the storage account:

```bash
# Get the storage account name from terraform output
STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)

# Get the service principal's client ID from the JSON above
CLIENT_ID="<paste-clientId-from-json>"

# Assign role
az role assignment create \
  --assignee $CLIENT_ID \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/8aed33d3-48a3-48f1-b05c-87b8a109cabf/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT
```

## Step 3: Add Secret to GitHub Repository

1. Go to your **terraform-course** repository on GitHub
2. Navigate to `Settings` → `Secrets and variables` → `Actions`
3. Click `New repository secret`
4. Name: `AZURE_CREDENTIALS`
5. Value: Paste the **entire JSON output** from Step 1
6. Click `Add secret`

## Step 4: Use in GitHub Actions Workflow

In your `terraform-course` repository, create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Infrastructure

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Verify Azure Connection
        run: |
          az account show
          echo "Successfully authenticated to Azure!"

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.3.0

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan

      # Uncomment to auto-apply on main branch
      # - name: Terraform Apply
      #   if: github.ref == 'refs/heads/main'
      #   run: terraform apply -auto-approve
```

## Security Notes

- The client secret is sensitive - treat it like a password
- Secrets are encrypted in GitHub and only exposed to workflow runs
- Consider rotating the secret periodically for security
- The service principal has Contributor role on your subscription - limit scope if needed

## Alternative: Scope to Resource Group Only

For better security, scope the service principal to just the resource group:

```bash
az ad sp create-for-rbac --name "github-actions-terraform-course" \
  --role "Contributor" \
  --scopes /subscriptions/8aed33d3-48a3-48f1-b05c-87b8a109cabf/resourceGroups/rg-infrastruktur \
  --sdk-auth
```
