# Azure AI Foundry Demo with Azure Developer CLI

This project contains Bicep configuration files that enable you to use Azure Developer CLI (`azd`) to provision Azure AI Foundry resources, including:

- **Azure AI Foundry Hub**: A centralized workspace for AI/ML development
- **Azure AI Project**: A project workspace within the hub for organizing your work
- **GPT-4o-mini Model Deployment**: A connection to the GPT-4o-mini model for chat completions

## Prerequisites

1. **Azure Developer CLI (azd)**: Install from [https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
2. **Azure CLI**: Install from [https://docs.microsoft.com/en-us/cli/azure/install-azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3. **PowerShell**: Required for the post-provision hooks
4. **Azure Subscription**: With sufficient permissions to create resources

## Architecture Overview

The deployment creates the following Azure resources:

```
Resource Group
├── AI Foundry Hub (ML Workspace)
│   ├── Storage Account
│   ├── Key Vault
│   ├── Application Insights
│   └── Log Analytics Workspace
├── AI Project (ML Workspace)
└── Model Connection (GPT-4o-mini)
```

## Project Structure

```
├── azure.yaml                    # Azure Developer CLI configuration
├── infra/
│   ├── main.bicep                # Main Bicep template
│   ├── main.bicepparam           # Parameters file
│   └── modules/
│       ├── ai-hub.bicep          # AI Foundry Hub and dependencies
│       ├── ai-project.bicep      # AI Project workspace
│       └── model-deployment.bicep # GPT-4o-mini model connection
└── README.md                     # This file
```

## Deployment Instructions

### Option 1: Using Azure Developer CLI (Recommended)

1. **Initialize and provision resources:**

   ```bash
   azd up
   ```

   This command will:

   - Prompt you to select an Azure subscription and region
   - Create a resource group
   - Deploy all Azure resources using the Bicep templates
   - Run post-provision hooks

2. **Access your AI Foundry resources:**
   - Navigate to [Azure AI Foundry Studio](https://ai.azure.com)
   - Your hub and project will be available in the interface

### Option 2: Manual Deployment with Azure CLI

1. **Login to Azure:**

   ```bash
   az login
   ```

2. **Create a resource group:**

   ```bash
   az group create --name rg-ai-foundry-demo-dev --location "East US"
   ```

3. **Deploy the Bicep template:**
   ```bash
   az deployment group create \
     --resource-group rg-ai-foundry-demo-dev \
     --template-file infra/main.bicep \
     --parameters infra/main.bicepparam
   ```

## Configuration

### Customizing the Deployment

You can modify the parameters in `infra/main.bicepparam`:

```bicep
// Project configuration
param projectName = 'your-project-name'    // Change this to your preferred name
param location = 'East US'                 // Change to your preferred region
param environmentSuffix = 'dev'            // dev, test, prod, etc.

// Resource tags
param tags = {
  Environment: 'Development'
  Project: 'Your Project Name'
  CreatedBy: 'Azure Developer CLI'
  Purpose: 'AI/ML Development'
}
```

### Supported Regions

Azure AI Foundry is available in the following regions:

- East US
- East US 2
- West US 2
- West Europe
- North Europe
- Southeast Asia

## Post-Deployment

### Accessing Azure AI Foundry Studio

After deployment, you can access your resources through:

1. **Azure AI Foundry Studio**: [https://ai.azure.com](https://ai.azure.com)
2. **Azure Portal**: Navigate to your resource group to see all created resources

### Using the GPT-4o-mini Model

The deployment creates a model connection that you can use in Azure AI Foundry:

1. Go to your AI Project in Azure AI Foundry Studio
2. Navigate to "Models + endpoints" → "Connections"
3. You'll find the `gpt-4o-mini-deployment` connection
4. Use this connection in your AI applications, prompt flows, or chat playground

## Resource Naming Convention

Resources are named using the following pattern:

- **AI Hub**: `{projectName}-hub-{environmentSuffix}`
- **AI Project**: `{projectName}-project-{environmentSuffix}`
- **Storage Account**: `{projectName}sa{environmentSuffix}` (alphanumeric only)
- **Key Vault**: `{projectName}-kv-{environmentSuffix}`
- **Application Insights**: `{projectName}-ai-{environmentSuffix}`
- **Log Analytics**: `{projectName}-law-{environmentSuffix}`

## Security and Access

### Managed Identity

All resources use system-assigned managed identities for secure authentication:

- The AI Hub has access to Storage, Key Vault, and Application Insights
- The AI Project has AzureML Data Scientist role on the Hub
- Model connections use Azure Active Directory authentication

### Role-Based Access Control (RBAC)

The deployment configures the following RBAC assignments:

- Hub managed identity: Key Vault Secrets Officer, Storage Blob Data Contributor
- Project managed identity: AzureML Data Scientist on the Hub

## Clean Up

To delete all resources:

```bash
azd down
```

Or delete the resource group manually:

```bash
az group delete --name rg-ai-foundry-demo-dev
```

## Troubleshooting

### Common Issues

1. **Deployment fails with permissions error**:

   - Ensure you have sufficient permissions in the Azure subscription
   - Required roles: Contributor or Owner on the subscription/resource group

2. **Resource name conflicts**:

   - Modify the `projectName` parameter to use a unique value
   - Some resources (like Storage Accounts) require globally unique names

3. **Region availability**:
   - Ensure Azure AI Foundry is available in your selected region
   - Check the supported regions list above

### Getting Help

- [Azure AI Foundry Documentation](https://learn.microsoft.com/en-us/azure/ai-services/agents/)
- [Azure Developer CLI Documentation](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
- [Azure Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)

## Contributing

This template follows Azure and Bicep best practices:

- Uses latest stable API versions
- Implements proper RBAC and security
- Follows Azure naming conventions
- Includes comprehensive documentation

Feel free to customize and extend this template for your specific needs!
