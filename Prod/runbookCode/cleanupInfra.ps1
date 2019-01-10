Param(
    $vm1 = @{
        name = "test-220-vm1"
        resourceGroup = "sm-test-220"
    },
    [System.Collections.ArrayList]
    $vmList = @($vm1)
)

#Region connection
try {
    $RunAsConnection = Get-AutomationConnection -Name "AzureRunAsConnection"         

    #Log into azure using run as account
    Write-Output ("Logging in to Azure...")
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $RunAsConnection.TenantId `
        -ApplicationId $RunAsConnection.ApplicationId `
        -CertificateThumbprint $RunAsConnection.CertificateThumbprint 

    Select-AzureRmSubscription -SubscriptionId $RunAsConnection.SubscriptionID  | Write-Verbose 
}
catch {
    if(!$RunAsConnection) {
        throw "Connection AzureRunAsConnection not found. Please create one"
    }
    else {
        throw $_.Exception
    }
}
#endregion

<#
The main foreach loop. This is to perform the actions for all VMs (one at a time) 
from the list specified in the param section.
#>
foreach ($vmInList in $vmList) {
    #Get the VM object, disk names, snapshots and NIC
    $vm = Get-AzureRmVM -ResourceGroup $vmInList.resourceGroup -Name $vmInList.name
    $vmname = $vm.name
    $osDiskName = $vm.StorageProfile.OsDisk.Name
    $dataDisksNameList = $vm.StorageProfile.DataDisks.Name
    $nic = Get-AzureRmNetworkInterface | Where-Object { $_.VirtualMachine.id -eq $vm.id}
    $nicName = $nic.Name

    #Remove the VM first, then disks, then NIC, then snapshots
    Write-Output "Removing VM $vmname"
    Remove-AzureRmVm -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name  -Force
    Write-Output "Removing OS disk $osDiskName"
    Remove-AzureRmDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $osDiskName -Force
    foreach ($dataDisk in $dataDisksNameList){
        Write-Output "Removing data disk $dataDisk"
        Remove-AzureRmDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $dataDisk -Force
    }
    Write-Output "Removing NIC $nicName"
    Remove-AzureRmNetworkInterface -ResourceGroupName $vm.ResourceGroupName -Name $nic.name -Force
    #Remove snapshots with the name of VMname-OSdisk-* as this will remove all OS disk snapshots
    Write-Output "Removing snapshots with name like $vmname-Osdisk"
    Get-AzureRmSnapshot | Where-Object name -Like "$vmname-OSdisk-*" | Remove-AzureRmSnapshot -Force
    #Go through disks attatched to VM and delete only the snapshots of those specific disks, not the "dr" versions
    foreach($dataDiskName in $dataDisksNameList){
        Write-Output "Remove snapshots with name like $vmname-$dataDiskName"
        #Get name of each data disk and append to vm name for full name of snapshots of that specific VM's disks
        Get-AzureRmSnapshot | Where-Object name -Like "$vmname-$dataDiskName-*" | Remove-AzureRmSnapshot -Force
    }
}