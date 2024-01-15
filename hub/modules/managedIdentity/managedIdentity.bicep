param managedIdentityName string
param location string
param tagValues object

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
  tags: tagValues
}

output managedIdentityResourceID string = managedIdentity.id
output managedIdentityPrincipalID string = managedIdentity.properties.principalId
