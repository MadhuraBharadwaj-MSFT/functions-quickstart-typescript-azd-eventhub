param name string
param location string = resourceGroup().location
param tags object = {}
param eventHubName string = 'input-events'
param outputEventHubName string = 'output-events'
param partitionCount int = 2
param retentionInDays int = 1
param vnetEnabled bool

// Create EventHub namespace using Azure Verified Module
module eventHubNamespace 'br/public:avm/res/event-hub/namespace:0.7.1' = {
  name: 'eventhub-namespace'
  params: {
    name: name
    location: location
    tags: tags
    skuName: 'Standard'
    eventhubs: [
      {
        name: eventHubName
        partitionCount: partitionCount
        retentionDescription: {
          retentionTimeInHours: retentionInDays * 24
        }
      }
      {
        name: outputEventHubName
        partitionCount: partitionCount
        retentionDescription: {
          retentionTimeInHours: retentionInDays * 24
        }
      }
    ]
    publicNetworkAccess: vnetEnabled ? 'Disabled' : 'Enabled'
    disableLocalAuth: true
  }
}

output eventHubNamespaceName string = eventHubNamespace.outputs.name
output eventHubNamespaceId string = eventHubNamespace.outputs.resourceId
