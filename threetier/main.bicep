param location string
param websubnet string
param appsubnet string
param tags object
param vnet string
param resourceGroupname string
param subname string
param dbsubnet string
param bastionsubnet string
param gatewaysubnet string
param hubaddress string

var numberOfInstances= 2
var subnetnsg = [
  appsubnet
  websubnet
  dbsubnet
]

resource sub 'Microsoft.Management/managementGroups/subscriptions@2021-04-01' existing={
  scope:tenant()
  name: subname
}

resource RG 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  scope:subscription('')
  name: resourceGroupname
}

//////////////////////////////////////Virtual Network///////////////////////////////

module virtualnetwork 'modules/vnet.bicep'= {
  name: 'Hubvnet'
  params: {
    appsubnet: appsubnet
    bastionsubnet: bastionsubnet
    dbsubnet: dbsubnet
    gatewaysubnet: gatewaysubnet
    hubaddress: hubaddress
    Hubvnet: 'hubvnet'
    networkSecurityGroups: 'networksecuritygroup'
    webappsubnet: websubnet
    location:location
  }
}

//////////////////////////NSG///////////////////////////////////////////////////////

module nsgweb 'modules/nsg.bicep'= [for (subnet, i) in subnetnsg:if (contains(subnetnsg, subnet)) {
  
  name: 'webnsg'
  params: {
    location: location
  }
  
}]
///////////////////////////WebVM///////////////////////////////////////////////

module webvm './modules/compute.bicep'= [for i in range(0, numberOfInstances): {
  name:'webvm'
  scope:RG
  params: {
    adminpassword: ''
    adminUsername: 'linuxadminuser'
    location: location
    offer: 'UbuntuServer'
    OsDiskType: 'Standard_LRS'
    ostype: 'Linux'
    publisher: 'RedHat'
    sku:'84-gen2' 
    subnet: websubnet
    subscriptionid: ''
    tags: tags
    virtualnetwork: vnet
    vm_name: 'webvm'
    vmsize: 'Standard_E2s_v3'
    vnetresourcegroup: ''
    loadbalancername:'loadbalancerweb'
  }
  dependsOn:[
    loadbalancer
  ]
  
}]

/////////////////////////////////AppVM////////////////////////////////////////////

module appvm './modules/compute.bicep'= [for i in range(0, numberOfInstances): {
  name:'appvm'
  scope:RG
  params: {
    adminpassword: ''
    adminUsername: 'linuxadminuser'
    location: location
    offer: 'UbuntuServer'
    OsDiskType: 'Standard_LRS'
    ostype: 'Linux'
    publisher: 'RedHat'
    sku:'84-gen2' 
    subnet: appsubnet
    subscriptionid: ''
    tags: tags
    virtualnetwork: vnet
    vm_name: 'appvm'
    vmsize: 'Standard_E2s_v3'
    vnetresourcegroup: ''
    loadbalancername:'loadbalancerapp'
  }
  dependsOn:[
    loadbalancerapp
  ]
}]

//////////////////////////////////////DBVM///////////////////////////////////////////

module dbvm './modules/compute.bicep'= [for i in range(0, numberOfInstances): {
  name:'dbvm'
  scope:RG
  params: {
    adminpassword: ''
    adminUsername: 'linuxadminuser'
    location: location
    offer: 'UbuntuServer'
    OsDiskType: 'Standard_LRS'
    ostype: 'Linux'
    publisher: 'RedHat'
    sku:'84-gen2' 
    subnet: dbsubnet
    subscriptionid: ''
    tags: tags
    virtualnetwork: vnet
    vm_name: 'dbvm'
    vmsize: 'Standard_E2s_v3'
    vnetresourcegroup: ''
    loadbalancername:'loadbalancerdb'
  }
  dependsOn:[
    loadbalancerdb
  ]
}]

module loadbalancer 'modules/loadbalancer.bicep'= {
  name: 'loadbalancerweb'
#disable-next-line explicit-values-for-loc-params
  params: {
    subnetRef: dbsubnet
  }
  dependsOn:[
    virtualnetwork
  ]
}

module loadbalancerapp 'modules/loadbalancer.bicep'= {
  name: 'loadbalancerapp'
#disable-next-line explicit-values-for-loc-params
  params: {
    subnetRef: appsubnet
  }
  dependsOn:[
    virtualnetwork
  ]
}

module loadbalancerdb 'modules/loadbalancer.bicep'= {
  name: 'loadbalancerdb'
#disable-next-line explicit-values-for-loc-params
  params: {
    subnetRef: dbsubnet
  }
  dependsOn:[
    virtualnetwork
  ]
}
