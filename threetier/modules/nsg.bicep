param location string
var securityRulesweb = [
  {
    name: 'access=web-http'
    direction: 'Inbound'
    protocol: '*'
    access: 'Allow'
    destinationPortRange: '80'
    sourcePortRange: '*'
    destinationAddressPrefix: '*'
    sourceAddressPrefix: '*'
    priority: 105
  }
  {
    name: 'access-wb-rdp'
    direction: 'Inbound'
    protocol: '*'
    access: 'Allow'
    destinationPortRange: '3389'
    sourcePortRange: '*'
    destinationAddressPrefix: '*'
    sourceAddressPrefix: '*'
    priority: 100
  }

  {
    name: 'access-web-outbound'
    direction: 'outbound'
    protocol: '*'
    access: 'Allow'
    destinationPortRange: '80'
    sourcePortRange: '*'
    destinationAddressPrefix: '*'
    sourceAddressPrefix: '*'
    priority: 100
  }
]

var securityRulesapp= [

]

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: 'nsg01'
  location:location
  properties: {}
}

resource nsgrulesweb 'Microsoft.Network/networkSecurityGroups/securityRules@2021-08-01' = [for rule in securityRulesweb: {
  name: rule.name
  parent: nsg
  properties: {
    direction: rule.direction
    protocol: rule.protocol
    access: rule.access
    destinationPortRange: rule.destinationPortRange
    sourcePortRange: rule.sourcePortRange
    destinationAddressPrefix: rule.destinationAddressPrefix
    sourceAddressPrefix: rule.sourceAddressPrefix
    priority: rule.priority
  }
  
}]
resource nsgrulesapp 'Microsoft.Network/networkSecurityGroups/securityRules@2021-08-01' = [for rule in securityRulesapp: {
  name: rule.name
  parent: nsg
  properties: {
    direction: rule.direction
    protocol: rule.protocol
    access: rule.access
    destinationPortRange: rule.destinationPortRange
    sourcePortRange: rule.sourcePortRange
    destinationAddressPrefix: rule.destinationAddressPrefix
    sourceAddressPrefix: rule.sourceAddressPrefix
    priority: rule.priority
  }
  
}]

