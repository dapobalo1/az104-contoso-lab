// Project 2, step 2.5: Contoso web VMs deployed as code.
// Deploy:
//   az deployment group create \
//     --resource-group rg-contoso-compute \
//     --template-file main.bicep \
//     --parameters adminUsername=contosoadmin
// (adminPassword is prompted, never stored in the repo.)
//
// Region comes from the resource group (Canada Central). Azure for Students
// only allows five regions; see the "As built" note in PROJECT_GUIDE.md A2.

param location string = resourceGroup().location
param adminUsername string
@secure()
param adminPassword string
@minValue(1)
@maxValue(3)
param vmCount int = 2
// Azure for Students in Canada Central only offers Standard_B2pts_v2 among the
// cheap B sizes (checked with az vm list-skus, 2026-11-20). It is ARM64, so
// the image SKU must be the arm64 build.
param vmSize string = 'Standard_B2pts_v2'
param imageSku string = 'server-arm64'

var tags = {
  env: 'lab'
  owner: 'dapo'
  project: 'az104-p2'
  costcenter: 'it'
}

// 1. Network: one VNet, one subnet. No public IPs anywhere in this project;
//    admin access is through Run command (step 2.7) and later Bastion (P4).
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-contoso-app'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-web'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}

// 2. One NIC per VM, private IP only. The subnet id is read from the VNet
//    above, which also makes Bicep deploy the VNet first (implicit dependency).
resource nics 'Microsoft.Network/networkInterfaces@2024-05-01' = [for i in range(0, vmCount): {
  name: 'nic-contoso-web0${i + 1}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}]

// 3. One Ubuntu 24.04 VM per NIC, each pinned to its own availability zone
//    (web01 -> zone 1, web02 -> zone 2).
resource vms 'Microsoft.Compute/virtualMachines@2024-07-01' = [for i in range(0, vmCount): {
  name: 'vm-contoso-web0${i + 1}'
  location: location
  tags: tags
  zones: [
    '${i + 1}'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'web0${i + 1}'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        name: 'osdisk-contoso-web0${i + 1}'
        createOption: 'FromImage'
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nics[i].id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true // managed storage, no storage account needed
      }
    }
  }
}]

// 4. Outputs show up on the deployment record in the portal.
output vmNames array = [for i in range(0, vmCount): vms[i].name]
output privateIps array = [for i in range(0, vmCount): nics[i].properties.ipConfigurations[0].properties.privateIPAddress]
