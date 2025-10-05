using 'main.bicep'

// Project configuration
param projectName = 'msagfwk-hsi'
param location = 'Sweden Central'
param environmentSuffix = 'dev'

// Resource tags
param tags = {
  Environment: 'Development'
  Project: 'Microsoft Agent Framework Demo'
  CreatedBy: 'Azure Developer CLI'
  Purpose: 'AI/ML Development'
}
