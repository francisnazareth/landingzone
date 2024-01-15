param location string
param tagValues object
param keyVaultSKU string 
param objectID string 
param keyVaultName string 

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName 
  location: location
  tags: tagValues
  properties: {
    sku: {
      name: keyVaultSKU
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: objectID
        permissions: {
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
            'list'
          ]
        }
      }
      
    ]
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: true
    enableRbacAuthorization: true
  }
}
