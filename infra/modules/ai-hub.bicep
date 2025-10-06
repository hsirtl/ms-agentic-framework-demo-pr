targetScope = 'resourceGroup'

@description('Name of the AI Foundry Hub')
param hubName string

@description('Location for resources')
param location string = resourceGroup().location

@description('Resource tags')
param tags object = {}

@description('Key Vault name')
param keyVaultName string

@description('Storage Account name')
param storageAccountName string

@description('Application Insights name')
param applicationInsightsName string

@description('Log Analytics Workspace name')
param logAnalyticsWorkspaceName string

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    defaultToOAuthAuthentication: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
  }
}

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
    accessPolicies: []
  }
}

// AI Foundry Hub (ML Workspace with Hub configuration)
resource aiFoundryHub 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: hubName
  location: location
  tags: union(tags, {
    'ai-foundry-resource-type': 'hub'
  })
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'Hub'
  properties: {
    friendlyName: hubName
    description: 'Azure AI Foundry Hub for ${hubName}'
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: applicationInsights.id
    publicNetworkAccess: 'Enabled'
    hbiWorkspace: false
    v1LegacyMode: false
  }
}

// Role assignments for the Hub's managed identity
// Note: These role assignments are typically created automatically by Azure ML
// or can be assigned manually through the Azure Portal if needed
/*
// Key Vault Secrets Officer role assignment
resource keyVaultSecretsOfficerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, aiFoundryHub.id, 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
    )
    principalId: aiFoundryHub.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Storage Blob Data Contributor role assignment
resource storageContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, aiFoundryHub.id, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    )
    principalId: aiFoundryHub.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
*/

// Outputs
@description('Resource ID of the AI Foundry Hub')
output hubResourceId string = aiFoundryHub.id

@description('Name of the AI Foundry Hub')
output hubName string = aiFoundryHub.name

@description('Principal ID of the Hub managed identity')
output hubPrincipalId string = aiFoundryHub.identity.principalId

@description('Storage Account resource ID')
output storageAccountId string = storageAccount.id

@description('Key Vault resource ID')
output keyVaultId string = keyVault.id

@description('Application Insights resource ID')
output applicationInsightsId string = applicationInsights.id
