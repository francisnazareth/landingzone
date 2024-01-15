param location string 
param tagValues object 
param vpnGatewayName string 
param availabilityZones array
param vpnGatewayPublicIPName string 
param vpnGatewaySubnetId string 
param vpnGatewayTier string 

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' =  {
  name: vpnGatewayPublicIPName
  location: location
  zones: availabilityZones
  tags: tagValues
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource virtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2023-04-01' = {
  name: vpnGatewayName
  location: location 
  tags: tagValues
  properties: {
    activeActive: false
    adminState: 'Enabled'
    allowRemoteVnetTraffic: true
    allowVirtualWanTraffic: false
 
    gatewayType: 'Vpn'
    sku:{
      name: vpnGatewayTier 
      tier: vpnGatewayTier
    }
    vpnGatewayGeneration: 'Generation2'
    vpnType: 'RouteBased'
    ipConfigurations: [{
      name: 'vpnGWIPConfiguration'
      properties:{
        privateIPAllocationMethod: 'Dynamic'
        publicIPAddress:{
          id: publicIpAddress.id
        }
        subnet:{
          id: vpnGatewaySubnetId
        }
      } 
    }]
  }
}
