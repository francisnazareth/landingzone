param vnetName string
param vnetAddressPrefix string
param fwSubnetAddressPrefix string
param bastionSubnetAddressPrefix string
param location string = resourceGroup().location
param appGwSubnetName string
param appGwSubnetAddressPrefix string
param vpnSubnetAddressPrefix string
param managementSubnetName string
param managementSubnetAddressPrefix string
param sharedServicesSubnetName string
param sharedServicesSubnetAddressPrefix string
param ddosProtectionPlanId string
param ddosProtectionPlanEnabled bool = true
param tagValues object
param vmNSGName string 
param peSubnetName string
param peSubnetAddressPrefix string

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: vmNSGName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  tags: tagValues
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }

    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: fwSubnetAddressPrefix
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetAddressPrefix
        }
      }      
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: vpnSubnetAddressPrefix
        }
      }
      {
        name: peSubnetName
        properties: {
          addressPrefix: peSubnetAddressPrefix
        }
      }
      {
        name: appGwSubnetName
        properties: {
          addressPrefix: appGwSubnetAddressPrefix
        }
      }
      {
        name: managementSubnetName
        properties: {
          addressPrefix: managementSubnetAddressPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
      {
        name: sharedServicesSubnetName
        properties: {
          addressPrefix: sharedServicesSubnetAddressPrefix
        }
      }
    ]

    enableDdosProtection: ddosProtectionPlanEnabled
    ddosProtectionPlan: {
      id: ddosProtectionPlanId
    }
  }

  resource firewallSubnet 'subnets' existing = {
      name: 'AzureFirewallSubnet'
  }

  resource bastionSubnet 'subnets' existing = {
      name: 'AzureBastionSubnet'
  }

  resource vpnSubnet 'subnets' existing = {
      name: 'GatewaySubnet'
  }

  resource appGwSubnet 'subnets' existing = {
      name: appGwSubnetName
  }

  resource managementSubnet 'subnets' existing = {
      name: managementSubnetName
  }

  resource sharedServicesSubnet 'subnets' existing = {
      name: sharedServicesSubnetName
  }
}

output vnetId string = vnet.id
output firewallSubnetID string = vnet::firewallSubnet.id
output bastionSubnetID string = vnet::bastionSubnet.id
output vpnSubnetID string = vnet::vpnSubnet.id
output appGwSubnetID string = vnet::appGwSubnet.id
output managementSubnetID string = vnet::managementSubnet.id
output sharedServicesSubnetID string = vnet::sharedServicesSubnet.id
