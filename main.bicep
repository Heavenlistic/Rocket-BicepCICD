targetScope = 'resourceGroup'

//  Parameters
param baseName string = 'la'
param location string = 'canadacentral'
param resourcePrefix string
param virtualNetworkPrefix string
param currentDate string = utcNow('yyyy-MM-dd')



// Must be unique name
var acrName = '${resourcePrefix}eshopondapracr'
// var baseName = '${resourcePrefix}-la'
var subnetname = '${resourcePrefix}-sn'
var tagValues = {
  CreatedBy: 'BICEPDeployment'
  deploymentDate: currentDate
}

module sta 'Modules/storageAccount.bicep' = {
  name: 'sta'
  params: {
    location: location  
    storageAccountPrefix: resourcePrefix
    tagValues: tagValues
  }
}

module nsg 'Modules/networkSecurityGroup.bicep' = {
  name: 'nsg'
  params: {
    location: location  
    ResourcePrefix: resourcePrefix
    tagValues: tagValues
    securityRules: []
  }
}

module vnet 'Modules/virtualNetwork.bicep' = {
  name: 'vnet'
  params: {
    location: location  
    ResourcePrefix: resourcePrefix
    virtualNetworkPrefix: virtualNetworkPrefix
    tagValues: tagValues
    subnets: [
      {
        name: subnetname
        virtualNetworkPrefix: replace(virtualNetworkPrefix, '10.0.0.0/16', '10.0.1.0/24')
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Disabled'
        nsg: nsg.outputs.nsgid
      }
    ]
  }
}

module privateEndPoint 'Modules/privateEndpoint.bicep' = {
  name: 'privateEndPoint'
  params: {
    location: location  
    tagValues: tagValues
    privateEndpointName: '${resourcePrefix}-pep'
    storageAccountId: sta.outputs.staid
    vnetId: vnet.outputs.vnetid
    subnetName: subnetname
  }
}

module akscluster 'Modules/akscluster.bicep' = {
  name: '${resourcePrefix}cluster'
  // scope: rg
  params: {
    location: location
    clusterName: resourcePrefix
  }
}

module akslaworkspace 'Modules/laworkspace.bicep' = {
  // scope: resourceGroup(rg.name)
  name: '${resourcePrefix}-akslaworkspace'
  params: {
    location: location  
    basename: baseName
   
  }
}

module acrDeploy 'Modules/acr.bicep' = {
  // scope: resourceGroup(rg.name)
  name: 'acrDeploy'
  params: {
    acrName: acrName
  }
}
