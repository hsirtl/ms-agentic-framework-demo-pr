targetScope = 'resourceGroup'

@description('Name of the AI Project/Workspace')
param workspaceName string

@description('Model name to deploy')
param modelName string = 'gpt-4o-mini'

@description('Deployment name for the model')
param deploymentName string = 'gpt-4o-mini-deployment'

@description('Location for the deployment')
param location string = resourceGroup().location





// Reference to the existing AI Project workspace
resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-10-01' existing = {
  name: workspaceName
}

// Create Azure OpenAI resource for GPT-4o-mini deployment
// This approach creates an Azure OpenAI service that appears in AI Foundry
resource azureOpenAI 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: '${deploymentName}-aoai'
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: '${deploymentName}-aoai'
    publicNetworkAccess: 'Enabled'
  }
}

// Deploy GPT-4o-mini model in the Azure OpenAI resource
resource gpt4oMiniDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: azureOpenAI
  name: deploymentName
  properties: {
    model: {
      format: 'OpenAI'
      name: modelName
      version: '2024-07-18'
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'Standard'
    capacity: 10
  }
}

// Create connection from AI Foundry project to Azure OpenAI
resource aoaiConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-10-01' = {
  parent: aiProject
  name: '${deploymentName}-connection'
  properties: {
    category: 'AzureOpenAI'
    target: azureOpenAI.properties.endpoint
    authType: 'AAD'
    isSharedToAll: true
    metadata: {
      ApiType: 'Azure'
      ApiVersion: '2024-10-01-preview'
      ResourceId: azureOpenAI.id
      DeploymentApiVersion: '2024-10-01'
      deploymentName: gpt4oMiniDeployment.name
      modelName: modelName
      modelVersion: '2024-07-18'
      description: 'Azure OpenAI GPT-4o-mini deployment connection'
    }
  }
}



// Outputs
@description('Name of the GPT-4o-mini deployment')
output deploymentName string = gpt4oMiniDeployment.name

@description('Azure OpenAI service ID')
output openaiId string = azureOpenAI.id

@description('Azure OpenAI endpoint URI')
output openaiEndpoint string = azureOpenAI.properties.endpoint

@description('Connection ID to AI Foundry project')
output connectionId string = aoaiConnection.id

@description('Model name')
output modelName string = modelName

@description('Azure OpenAI service name')
output openaiServiceName string = azureOpenAI.name
