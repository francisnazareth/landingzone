param location string
param firewallPublicIPName string
param firewallPolicyName string
param firewallSubnetID string
param firewallName string
@description('Zone numbers e.g. 1,2,3.')
param availabilityZones array = []
param tagValues object
param aksSubnetRange array 
param jumpVMAddressRange array 

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' =  {
  name: firewallPublicIPName
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

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-01-01'= {
  name: firewallPolicyName
  location: location
  tags: tagValues

  properties: {
    dnsSettings: {
      enableProxy: true
    }

    sku: {
      tier: 'Premium'
    }
    threatIntelMode: 'Deny'
    intrusionDetection: {
      mode: 'Deny'
    }
  }
}

output firewallPolicyId string = firewallPolicy.id

resource networkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = {
  parent: firewallPolicy
  name: 'DefaultNetworkRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        name: 'aks-cluster-network-rule-collection'
        priority: 1250
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'aks-api-udp-rule'
            ipProtocols: [
              'UDP'
            ]
            destinationAddresses: [
              'AzureCloud.qatarcentral'
            ]
            sourceAddresses: aksSubnetRange
            destinationPorts: [
              '1194'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'aks-api-tcp-rule'
            ipProtocols: [
              'TCP'
            ]
            destinationAddresses: [
              'AzureCloud.qatarcentral'
            ]
            sourceAddresses: aksSubnetRange
            destinationPorts: [
              '9000'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'time-server-udp-rule'
            ipProtocols: [
              'UDP'
            ]
            destinationFqdns: [
              'ntp.ubuntu.com'
            ]
            sourceAddresses: aksSubnetRange
            destinationPorts: [
              '123'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'gchr-tcp-rule'
            ipProtocols: [
              'TCP'
            ]
            destinationFqdns: [
              'gcr.io'
            ]
            sourceAddresses: aksSubnetRange
            destinationPorts: [
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'dockerhub-tcp-rule'
            ipProtocols: [
              'TCP'
            ]
            destinationFqdns: [
              'registry-1.docker.io'
              'docker.io'
              'production.cloudflare.docker.com'
            ]
            sourceAddresses: aksSubnetRange
            destinationPorts: [
              '443'
            ]
          }
        ]
      }
    ]
  }
}

resource applicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = {
  parent: firewallPolicy
  name: 'DefaultApplicationRuleCollectionGroup'
  dependsOn: [
    networkRuleCollectionGroup
  ]
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'aks-application-rule-collection'
        priority: 1000
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'aks-application-rule-01'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            fqdnTags: [
              'AzureKubernetesService'
            ]
            terminateTLS: false
            sourceAddresses: aksSubnetRange
          }
        ]
      }

      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'global-rule-windows-update'
        priority: 1100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'winupdate-rule-01'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            fqdnTags: [
              'WindowsUpdate'
            ]
            terminateTLS: false
            sourceAddresses: jumpVMAddressRange
          }
        ]
      }

    ]
  }
}

var azureFirewallIpConfigurations = [{
  name: 'IpConf1'
    properties: {
    subnet:  json('{"id": "${firewallSubnetID}"}')
    publicIPAddress: {
      id: publicIpAddress.id
    }
  }
}]

resource firewall 'Microsoft.Network/azureFirewalls@2021-03-01' = {
  name: firewallName
  location: location
  zones: availabilityZones
  tags: tagValues

  dependsOn: [
    networkRuleCollectionGroup
    applicationRuleCollectionGroup
  ]
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Premium'
    }
    ipConfigurations: azureFirewallIpConfigurations
    firewallPolicy: {
      id: firewallPolicy.id
    }
  }
}

output firewallPrivateIP string = firewall.properties.ipConfigurations[0].properties.privateIPAddress

