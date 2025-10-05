targetScope = 'resourceGroup'

@description('Name for the AI Foundry hub and project resources')
param projectName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Environment suffix (e.g., dev, prod)')
param environmentSuffix string = 'dev'

@description('Resource tags')
param tags object = {}

// Variables for resource naming
var hubName = '${projectName}-hub-${environmentSuffix}'
var aiProjectName = '${projectName}-project-${environmentSuffix}'
var keyVaultName = '${projectName}-kv-${environmentSuffix}'
var storageAccountName = '${replace(projectName, '-', '')}sa${environmentSuffix}'
var applicationInsightsName = '${projectName}-ai-${environmentSuffix}'
var logAnalyticsWorkspaceName = '${projectName}-law-${environmentSuffix}'

// Create the AI Foundry Hub (ML Workspace) with required dependencies
module aiHub 'modules/ai-hub.bicep' = {
  name: 'aiHub-deployment'
  params: {
    hubName: hubName
    location: location
    tags: tags
    keyVaultName: keyVaultName
    storageAccountName: storageAccountName
    applicationInsightsName: applicationInsightsName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

// Create the AI Project
module aiProject 'modules/ai-project.bicep' = {
  name: 'aiProject-deployment'
  params: {
    projectName: aiProjectName
    location: location
    tags: tags
    hubResourceId: aiHub.outputs.hubResourceId
    hubName: hubName
  }
}

// Deploy GPT-4o-mini model
module modelDeployment 'modules/model-deployment.bicep' = {
  name: 'model-deployment'
  params: {
    workspaceName: aiProjectName
    modelName: 'gpt-4o-mini'
    deploymentName: 'gpt-4o-mini'
    location: location
  }
  dependsOn: [
    aiProject
  ]
}

// Outputs
@description('Resource ID of the AI Foundry Hub')
output hubResourceId string = aiHub.outputs.hubResourceId

@description('Name of the AI Foundry Hub')
output hubName string = hubName

@description('Resource ID of the AI Project')
output projectResourceId string = aiProject.outputs.projectResourceId

@description('Name of the AI Project')
output projectName string = aiProjectName

@description('Model deployment name')
output modelDeploymentName string = modelDeployment.outputs.deploymentName

@description('AI Foundry Studio URL')
output studioUrl string = 'https://ai.azure.com/build/hub/${aiHub.outputs.hubResourceId}'
