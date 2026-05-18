targetScope = 'subscription'

param location string
param yourIp string
param adminUsername string
param sshPublicKey string

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-k8s-lab'
  location: location
}

module nsg 'modules/nsg.bicep' = {
  name: 'nsg'
  scope: rg
  params: {
    location: location
    yourIp: yourIp
  }
}

module network 'modules/network.bicep' = {
  name: 'network'
  scope: rg
  params: {
    location: location
    nsgId: nsg.outputs.nsgId
  }
}

module vmControlplane 'modules/vm.bicep' = {
  name: 'vm-controlplane'
  scope: rg
  params: {
    location: location
    vmName: 'vm-controlplane'
    privateIp: '10.0.1.10'
    subnetId: network.outputs.controlplaneSubnetId
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
  }
}

module vmWorker1 'modules/vm.bicep' = {
  name: 'vm-worker-1'
  scope: rg
  params: {
    location: location
    vmName: 'vm-worker-1'
    privateIp: '10.0.2.11'
    subnetId: network.outputs.workerSubnetId
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
  }
}

module vmWorker2 'modules/vm.bicep' = {
  name: 'vm-worker-2'
  scope: rg
  params: {
    location: location
    vmName: 'vm-worker-2'
    privateIp: '10.0.2.12'
    subnetId: network.outputs.workerSubnetId
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
  }
}
