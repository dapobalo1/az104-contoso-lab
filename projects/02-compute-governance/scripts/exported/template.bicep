param networkInterfaces_nic_contoso_web01_name string
param networkInterfaces_nic_contoso_web02_name string
param virtualMachines_vm_contoso_web01_name string
param virtualMachines_vm_contoso_web02_name string
param virtualNetworks_vnet_contoso_app_name string

resource virtualNetworks_vnet_contoso_app_name_resource 'Microsoft.Network/virtualNetworks@2025-09-01' = {
  location: 'canadacentral'
  name: virtualNetworks_vnet_contoso_app_name
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    enableDdosProtection: false
    privateEndpointVNetPolicies: 'Disabled'
    subnets: [
      {
        id: virtualNetworks_vnet_contoso_app_name_snet_web.id
        name: 'snet-web'
        properties: {
          addressPrefix: '10.1.1.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
  }
  tags: {
    costcenter: 'it'
    env: 'lab'
    owner: 'dapo'
    project: 'az104-p2'
  }
}

resource virtualMachines_vm_contoso_web01_name_resource 'Microsoft.Compute/virtualMachines@2026-04-01' = {
  location: 'canadacentral'
  name: virtualMachines_vm_contoso_web01_name
  properties: {
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_B2pts_v2'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_nic_contoso_web01_name_resource.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    osProfile: {
      adminUsername: 'contosoadmin'
      allowExtensionOperations: true
      computerName: 'web01'
      linuxConfiguration: {
        disablePasswordAuthentication: false
        enableVMAgentPlatformUpdates: true
        patchSettings: {
          assessmentMode: 'ImageDefault'
          patchMode: 'ImageDefault'
        }
        provisionVMAgent: true
      }
      requireGuestProvisionSignal: true
      secrets: []
    }
    securityProfile: {
      securityType: 'Standard'
    }
    storageProfile: {
      dataDisks: []
      diskControllerType: 'SCSI'
      imageReference: {
        offer: 'ubuntu-24_04-lts'
        publisher: 'Canonical'
        sku: 'server-arm64'
        version: 'latest'
      }
      osDisk: {
        caching: 'ReadWrite'
        createOption: 'FromImage'
        deleteOption: 'Delete'
        diskSizeGB: 30
        managedDisk: {
          id: resourceId('Microsoft.Compute/disks', 'osdisk-contoso-web01')
          storageAccountType: 'StandardSSD_LRS'
        }
        name: 'osdisk-contoso-web01'
        osType: 'Linux'
      }
    }
  }
  tags: {
    costcenter: 'it'
    env: 'lab'
    owner: 'dapo'
    project: 'az104-p2'
  }
  zones: [
    '1'
  ]
}

resource virtualMachines_vm_contoso_web02_name_resource 'Microsoft.Compute/virtualMachines@2026-04-01' = {
  location: 'canadacentral'
  name: virtualMachines_vm_contoso_web02_name
  properties: {
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_B2pts_v2'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_nic_contoso_web02_name_resource.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    osProfile: {
      adminUsername: 'contosoadmin'
      allowExtensionOperations: true
      computerName: 'web02'
      linuxConfiguration: {
        disablePasswordAuthentication: false
        enableVMAgentPlatformUpdates: true
        patchSettings: {
          assessmentMode: 'ImageDefault'
          patchMode: 'ImageDefault'
        }
        provisionVMAgent: true
      }
      requireGuestProvisionSignal: true
      secrets: []
    }
    securityProfile: {
      securityType: 'Standard'
    }
    storageProfile: {
      dataDisks: []
      diskControllerType: 'SCSI'
      imageReference: {
        offer: 'ubuntu-24_04-lts'
        publisher: 'Canonical'
        sku: 'server-arm64'
        version: 'latest'
      }
      osDisk: {
        caching: 'ReadWrite'
        createOption: 'FromImage'
        deleteOption: 'Delete'
        diskSizeGB: 30
        managedDisk: {
          id: resourceId('Microsoft.Compute/disks', 'osdisk-contoso-web02')
          storageAccountType: 'StandardSSD_LRS'
        }
        name: 'osdisk-contoso-web02'
        osType: 'Linux'
      }
    }
  }
  tags: {
    costcenter: 'it'
    env: 'lab'
    owner: 'dapo'
    project: 'az104-p2'
  }
  zones: [
    '2'
  ]
}

resource networkInterfaces_nic_contoso_web01_name_resource 'Microsoft.Network/networkInterfaces@2025-09-01' = {
  kind: 'Regular'
  location: 'canadacentral'
  name: networkInterfaces_nic_contoso_web01_name
  properties: {
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
    disableTcpStateTracking: false
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    ipConfigurations: [
      {
        id: '${networkInterfaces_nic_contoso_web01_name_resource.id}/ipConfigurations/ipconfig1'
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAddress: '10.1.1.5'
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetworks_vnet_contoso_app_name_snet_web.id
          }
        }
      }
    ]
    nicType: 'Standard'
  }
  tags: {
    costcenter: 'it'
    env: 'lab'
    owner: 'dapo'
    project: 'az104-p2'
  }
}

resource networkInterfaces_nic_contoso_web02_name_resource 'Microsoft.Network/networkInterfaces@2025-09-01' = {
  kind: 'Regular'
  location: 'canadacentral'
  name: networkInterfaces_nic_contoso_web02_name
  properties: {
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
    disableTcpStateTracking: false
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    ipConfigurations: [
      {
        id: '${networkInterfaces_nic_contoso_web02_name_resource.id}/ipConfigurations/ipconfig1'
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAddress: '10.1.1.4'
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetworks_vnet_contoso_app_name_snet_web.id
          }
        }
      }
    ]
    nicType: 'Standard'
  }
  tags: {
    costcenter: 'it'
    env: 'lab'
    owner: 'dapo'
    project: 'az104-p2'
  }
}

resource virtualNetworks_vnet_contoso_app_name_snet_web 'Microsoft.Network/virtualNetworks/subnets@2025-09-01' = {
  name: '${virtualNetworks_vnet_contoso_app_name}/snet-web'
  properties: {
    addressPrefix: '10.1.1.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworks_vnet_contoso_app_name_resource
  ]
}
