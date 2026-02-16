# Instructions: Create GitHub Actions Service Principal for Terraform Deployment

## Overview

This guide explains how to create an Azure service principal that will authenticate GitHub Actions workflows to Azure for infrastructure deployment using Terraform.

---

## Prerequisites

- Azure CLI installed and authenticated with permissions to create service principals
- Access to Azure AD application management permissions

---

## Installation & Authentication (If Needed)

If you don't have Azure CLI installed:

```bash
# macOS
brew install azure-cli

# Windows
choco install azure-cli

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

Authenticate:
```bash
az login
```

---

## Step 1: Create the Service Principal

Run this command in your terminal:

```bash
az ad sp create-for-rbac \
  --name "github-actions-terraform-course" \
  --role "Contributor" \
  --scopes /subscriptions/8aed33d3-48a3-48f1-b05c-87b8a109cabf
```

### What This Command Does:
- **`--name`**: Creates a service principal named "github-actions-terraform-course"
- **`--role "Contributor"`**: Grants Contributor role (full permissions to manage Azure resources)
- **`--scopes`**: Limits permissions to only the specified Azure subscription

---

## Step 2: Save the Output

The command will output JSON credentials that look like this:

```json
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "github-actions-terraform-course",
  "password": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

**IMPORTANT**: Copy this entire JSON output and send it securely to Sebastian (not via email, chat logs, or Slack - use a secure method).

### Key Fields Explained:
- **appId**: Client ID (public)
- **password**: Client Secret (MUST keep secure, like a password)
- **tenant**: Tenant ID (public)
- **displayName**: Service principal name

---

## Step 3: Verify the Service Principal (Optional)

To verify the service principal was created successfully:

```bash
# List the service principal
az ad sp show --id "github-actions-terraform-course"

# View the role assignment
az role assignment list --assignee "github-actions-terraform-course"
```

---

## Step 4: Send Credentials Securely

**DO NOT** share credentials via:
- ❌ Email
- ❌ Slack
- ❌ Teams chat
- ❌ Any messaging platform with logging

**DO** share via:
- ✅ Encrypted password manager
- ✅ Secure file transfer (OneDrive private share)
- ✅ In-person/phone call
- ✅ Password-protected document

---

## Security Best Practices

1. **Never log credentials** - Don't paste them in chat or email
2. **Rotate periodically** - Service principal credentials should be rotated every 90 days
3. **Limit scope** - This service principal is scoped to one subscription only
4. **Monitor usage** - Review sign-in logs for unusual activity

### If Credentials Are Compromised:

```bash
# Delete the service principal immediately
az ad sp delete --id "github-actions-terraform-course"

# Create a new one with a different name
az ad sp create-for-rbac \
  --name "github-actions-terraform-course-v2" \
  --role "Contributor" \
  --scopes /subscriptions/8aed33d3-48a3-48f1-b05c-87b8a109cabf
```

---

## What Happens Next

After you provide the credentials to Sebastian, he will:

1. Store the JSON in GitHub as an encrypted secret named `AZURE_CREDENTIALS`
2. Configure GitHub Actions workflows to use those credentials
3. GitHub Actions will use this service principal to deploy Terraform infrastructure

The service principal will:
- ✅ Be used ONLY by GitHub Actions workflows
- ✅ Have automatic access to manage Azure resources in the specified subscription
- ✅ NOT be used by any human user

---

## Questions?

If you have any questions about creating this service principal, refer to:
- [Microsoft Documentation: Create Azure Service Principal](https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)
- [Azure GitHub Actions Documentation](https://learn.microsoft.com/en-us/azure/developers/github/connect-from-azure)

---

**Prepared for**: Sebastian Henze  
**Date**: 6 February 2026  
**Purpose**: GitHub Actions CI/CD authentication for terraform-course repository
