# Request for Azure AD Administrator

## Subject: Request for Service Principal Creation for GitHub Actions CI/CD

---

Dear Azure AD Administrator,

I am setting up automated infrastructure deployment for our Terraform project using GitHub Actions. To enable secure authentication between GitHub Actions and Azure, I need a service principal created.

### What I Need

Please create a service principal with the following specifications:

**Name:** `github-actions-terraform-course`  
**Role:** `Contributor`  
**Scope:** Subscription: `8aed33d3-48a3-48f1-b05c-87b8a109cabf`

### Command to Run

```bash
az ad sp create-for-rbac --name "github-actions-terraform-course" \
  --role "Contributor" \
  --scopes /subscriptions/8aed33d3-48a3-48f1-b05c-87b8a109cabf
```

This command will output JSON credentials that look like this:

```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "8aed33d3-48a3-48f1-b05c-87b8a109cabf",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  ...
}
```

### What I'll Do With It

I will store this JSON output as an encrypted secret in our GitHub repository to enable automated Terraform deployments. The credentials will be used exclusively by GitHub Actions workflows to deploy Azure infrastructure.

### Security Notes

- The service principal will have Contributor access only to the specified subscription
- Credentials will be stored encrypted in GitHub Secrets (never in code)
- This follows Microsoft's recommended approach for CI/CD authentication
- No user credentials will be stored or exposed

### Alternative: Grant Me Azure AD Permissions

If you prefer, you could grant me the **Application Administrator** role in Azure AD, which would allow me to create service principals myself for future automation needs.

---

**Please send me the complete JSON output securely** (via secure messaging/email, not Slack/Teams where it might be logged).

Thank you for your assistance!

Best regards,
Sebastian Henze
