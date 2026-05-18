param location string
param nsgId string

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'vnet-k8s'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'snet-controlplane'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: { id: nsgId }
        }
      }
      {
        name: 'snet-workers'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: { id: nsgId }
        }
      }
    ]
  }
}

output controlplaneSubnetId string = vnet.properties.subnets[0].id
output workerSubnetId string = vnet.properties.subnets[1].id
