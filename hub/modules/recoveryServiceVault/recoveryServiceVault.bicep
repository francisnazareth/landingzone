param location string
param vaultName string 
param tagValues object

resource recoveryServiceVault 'Microsoft.RecoveryServices/vaults@2023-06-01' = {
  name: vaultName
  location: location
  tags: tagValues
  sku: {
      name: 'RS0'
      tier: 'Standard'
  }
  properties:{
    publicNetworkAccess: 'Enabled'
  }
}
