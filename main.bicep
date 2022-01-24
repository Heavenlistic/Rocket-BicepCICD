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
// module logAnalytics 'Modules/log-analytics.bicep' = {
//   name: 'log-analytics.bicep'
//   params: {
//     location: location
//     logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
//     logAnalyticsSku: logAnalyticsSku
//     logAnalyticsRetentionInDays: logAnalyticsRetentionInDays
//   }
// }
// module aks 'Modules/aks-cluster.bicep' = {
//   name: 'aks'
//   params: {
//     location: location

//     aadEnabled: aadEnabled
//     aadProfileAdminGroupObjectIDs: aadProfileAdminGroupObjectIDs
//     aadProfileEnableAzureRBAC: aadProfileEnableAzureRBAC
//     aadProfileManaged: aadProfileManaged
//     aadProfileTenantId: aadProfileTenantId
//     aksClusterAdminUsername: aksClusterAdminUsername
//     aksClusterDnsPrefix: aksClusterDnsPrefix
//     aksClusterDnsServiceIP: aksClusterDnsServiceIP
//     aksClusterDockerBridgeCidr: aksClusterDockerBridgeCidr
//     aksClusterEnablePrivateCluster: aksClusterEnablePrivateCluster
//     aksClusterKubernetesVersion: aksClusterKubernetesVersion
//     aksClusterLoadBalancerSku: aksClusterLoadBalancerSku
//     aksClusterName: aksClusterName
//     aksClusterNetworkPlugin: aksClusterNetworkPlugin
//     aksClusterNetworkPolicy: aksClusterNetworkPolicy
//     aksClusterPodCidr: aksClusterPodCidr
//     aksClusterServiceCidr: aksClusterServiceCidr
//     aksClusterSkuTier: aksClusterSkuTier
//     aksClusterSshPublicKey: aksClusterSshPublicKey
//     aksClusterTags: aksClusterTags
//     aksSubnetName: aksSubnetName

//     nodePoolAvailabilityZones: nodePoolAvailabilityZones
//     nodePoolCount: nodePoolCount
//     nodePoolEnableAutoScaling: nodePoolEnableAutoScaling
//     nodePoolMaxCount: nodePoolMaxCount
//     nodePoolMaxPods: nodePoolMaxPods
//     nodePoolMinCount: nodePoolMinCount
//     nodePoolMode: nodePoolMode
//     nodePoolName: nodePoolName
//     nodePoolNodeLabels: nodePoolNodeLabels
//     nodePoolNodeTaints: nodePoolNodeTaints
//     nodePoolOsDiskSizeGB: nodePoolOsDiskSizeGB
//     nodePoolOsType: nodePoolOsType
//     nodePoolScaleSetPriority: nodePoolScaleSetPriority
//     nodePoolType: nodePoolType
//     nodePoolVmSize: nodePoolVmSize

//     virtualNetworkId: vnet.outputs.virtualNetworkResourceId
//     logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
//   }
// }
module aks './aks-cluster.bicep' = {
  name: '${resourcePrefix}cluster'
  scope: rg
  params: {
    location: location
    clusterName: resourcePrefix
  }
}
