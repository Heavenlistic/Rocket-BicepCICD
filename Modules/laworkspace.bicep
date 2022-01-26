
// param basename string
param logAnalyticsWorkspaceName string = 'la-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location

resource logworkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: logAnalyticsWorkspaceName //'${basename}-workspace'
  location: location
}

output laworkspaceId string = logworkspace.id
