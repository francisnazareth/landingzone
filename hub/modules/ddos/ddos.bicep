param ddosProtectionPlanName string
param ddosPlanEnabled bool
param location string
param tagValues object

resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2021-05-01' = if(ddosPlanEnabled) {
  name: ddosProtectionPlanName
  location: location
  tags: tagValues
}

output ddosProtectionPlanId string = ddosProtectionPlan.id
