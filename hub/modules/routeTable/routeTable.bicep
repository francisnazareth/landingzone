param location string 
param tagValues object
param routeTableName string  
param vmSubnetAddressPrefix string 
param firewallIP string

resource routeTable 'Microsoft.Network/routeTables@2023-06-01' = {
  name: routeTableName
  location: location
  tags: tagValues
  properties: {
    routes: [
      {
        name: 'route-vm-traffic-to-firewall'
        properties: {
          addressPrefix: vmSubnetAddressPrefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIP
        }
      }
      {
        name: 'route-all-traffic-to-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallIP
        }
      }
    ]
  }
}

