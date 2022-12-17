param vm_name string 
param OsDiskType string 
param location string
param subscriptionid string
param vnetresourcegroup string
param virtualnetwork string
param subnet string
param tags object
param vmsize string
param publisher string
param offer string
param sku string
param ostype string
param adminUsername string
param adminpassword string
param loadbalancername string



var VM_SubnetId = '/subscriptions/${subscriptionid}/resourceGroups/${vnetresourcegroup}/providers/Microsoft.Network/virtualNetworks/${virtualnetwork}/subnets/${subnet}'

resource networkInterface 'Microsoft.Network/networkInterfaces@2018-10-01' = {
  name: '${vm_name}-NIC'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: VM_SubnetId
          }
          loadBalancerBackendAddressPools:[
            {
              id:resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadbalancername, 'BackendPool1')
            }
          ]
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
  
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vm_name 
  location: location
  tags:tags
  properties: {
    hardwareProfile: {
      vmSize: vmsize
    }
    storageProfile: {
      imageReference: {
        publisher: publisher
        offer: offer
        sku: sku
        version: 'latest'
      }
      osDisk: {
        osType: ostype
        name: '${vm_name }_OsDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: OsDiskType
          
        }
        deleteOption: 'Detach'
        diskSizeGB: '256'
      }

      dataDisks:[
        {
          diskSizeGB:512
          lun:0
          createOption:'Empty'
          managedDisk:{
            storageAccountType:'StandardSSD_LRS'
          }
        }
      ]

      
      
      
    }
    osProfile: {
      computerName: vm_name 
      adminUsername: adminUsername
      adminPassword:adminpassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
