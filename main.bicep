targetScope = 'resourceGroup'

//  Parameters
param resourcePrefix string
param virtualNetworkPrefix string
param currentDate string = utcNow('yyyy-MM-dd')

var subnetname = '${resourcePrefix}-sn'
var tagValues = {
  CreatedBy: 'BICEPDeployment'
  deploymentDate: currentDate
}

module sta 'Modules/storageAccount.bicep' = {
  name: 'sta'
  params: {
    storageAccountPrefix: resourcePrefix
    tagValues: tagValues
  }
}

module nsg 'Modules/networkSecurityGroup.bicep' = {
  name: 'nsg'
  params: {
    ResourcePrefix: resourcePrefix
    tagValues: tagValues
    securityRules: []
  }
}

module vnet 'Modules/virtualNetwork.bicep' = {
  name: 'vnet'
  params: {
    ResourcePrefix: resourcePrefix
    virtualNetworkPrefix: virtualNetworkPrefix
    tagValues: tagValues
    subnets: [
      {
        name: subnetname
        virtualNetworkPrefix: replace(virtualNetworkPrefix, '0.0/16', '1.0/24')
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
    // location: location
    clusterName: resourcePrefix
  }
}

module akslaworkspace 'Modules/laworkspace.bicep' = {
  // scope: resourceGroup(rg.name)
  name: '${resourcePrefix}akslaworkspace'
  params: {
    // basename: baseName
  }
}

module acrDeploy 'Modules/acr.bicep' = {
  // scope: resourceGroup(rg.name)
  name: 'acrDeploy'
  params: {
    // acrName: acrName
  }
}
