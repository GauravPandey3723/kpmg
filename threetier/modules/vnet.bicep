////05-12-2022: Gaurav - Initial Template

param Hubvnet string 
param networkSecurityGroups string 
param location string = resourceGroup().location
param hubaddress string


param gatewaysubnet string  
param webappsubnet string
param appsubnet string
param dbsubnet string
param bastionsubnet string



resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: Hubvnet
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubaddress
      ]
    }
   
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaysubnet

          
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'webappsubnet'
        properties: {
          addressPrefix: webappsubnet
          

          
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      
      {
        name: 'appsubnet'
        properties: {
          addressPrefix: appsubnet
          networkSecurityGroup: {
            id: networkSecurityGroups
          }

          
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'dbsubnet'
        properties: {
          addressPrefix: dbsubnet
          networkSecurityGroup: {
            id: networkSecurityGroups
          }
         

          
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionsubnet
         
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      
    ]
   
    enableDdosProtection: false
  }
}









