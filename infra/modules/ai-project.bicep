targetScope = 'resourceGroup'

@description('Name of the AI Project')
param projectName string

@description('Location for resources')
param location string = resourceGroup().location

@description('Resource tags')
param tags object = {}

@description('Resource ID of the AI Foundry Hub')
param hubResourceId string

@description('Name of the Hub (for reference)')
param hubName string

// AI Project (ML Workspace with Project configuration)
resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: projectName
  location: location
  tags: union(tags, {
    'ai-foundry-resource-type': 'project'
    'hub-name': hubName
  })
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'Project'
  properties: {
    friendlyName: projectName
    description: 'Azure AI Foundry Project for ${projectName}'
    hubResourceId: hubResourceId
    publicNetworkAccess: 'Enabled'
    hbiWorkspace: false
    v1LegacyMode: false
  }
}

// Role assignment: AzureML Data Scientist role on the hub for the project's managed identity
// Note: This role assignment is typically created automatically by Azure ML
// or can be assigned manually through the Azure Portal if needed
/*
resource azureMLDataScientistRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(hubResourceId, aiProject.id, 'f6c7c914-8db3-469d-8ca1-694a8f32e121')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f6c7c914-8db3-469d-8ca1-694a8f32e121')
    principalId: aiProject.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
*/

// Outputs
@description('Resource ID of the AI Project')
output projectResourceId string = aiProject.id

@description('Name of the AI Project')
output projectName string = aiProject.name

@description('Principal ID of the Project managed identity')
output projectPrincipalId string = aiProject.identity.principalId
