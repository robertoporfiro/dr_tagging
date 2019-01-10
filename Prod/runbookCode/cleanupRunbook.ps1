Param(
    $vm1 = @{
        name = "bf-suse-01"
        resourceGroup = "bf-dr-dan-eu"
        subscriptionId = "23666e70-4091-4ab9-929c-9ef08446f52e"
        # saName = "saName"
    },
    $vm2 = @{
        name = "bf-suse-02"
        resourceGroup = "bf-dr-dan-eu"
        subscriptionId = "23666e70-4091-4ab9-929c-9ef08446f52e"
        # saName = "saName"
    },
    [System.Collections.ArrayList]
    $vmList = @($vm1,$vm2)
)
<#
This variable is used to control how many snapshots to keep. 
All snapshots that are above the number specified here will be removed.
#>
$numberOfSnapshots = 10

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
    #this block is used to get all of the VMs including failed over ones
    $rgVar = Get-AzureRmResourceGroup -name $vmInList.resourceGroup
    $uri = $rgVar.ResourceId + "/providers/Microsoft.Compute/virtualMachines/" + $vmInList.name
    $vmObjs= Get-AzureRmVM | Where-Object { $_.id -like "$uri*"}

    #this is used to select the most recent failed over VM
    if ($vmObjs.Length -eq "1"){
        $vm = $vmObjs
    }elseif ($vmObjs.Length -gt "1"){
        $vmObjs = $vmObjs | Sort-Object -Property Name -Descending
        $vm = $vmObjs[0]
    }

    $vmName = $vm.Name

    Write-Output "Finding all OS snapshots..."
    #this is used to get all of the OS disk snapshots of a VM, newest first
    $allVmOsDiskSnapshots = Get-AzureRmSnapshot | `
        Where-Object name -Like "$vmName-OSdisk-*" | `
        Sort-Object name –Descending

    #this is used to ignore the first X snapshots, where X is the number to keep
    for ($i=$numberOfSnapshots; $i -lt $allVmOsDiskSnapshots.Count; $i++) {
        $rg = $allVmOsDiskSnapshots[$i].resourceGroupName
        $osSnapshotName = $allVmOsDiskSnapshots[$i].name
        #parse the seconds since epoch (all snapshots taken at that time will have the same value)
        $ssepoch = $osSnapshotName.Substring($osSnapshotName.Length -16)
        Write-Output "Removing snapshot: $osSnapshotName"
        #delete the snapshots that match the VM name and the seconds since epoch (basically that snapshot set)
        $deletedisks = Get-AzureRmSnapshot | `
        Where-Object name -Like "*$vmName*" | `
        Where-Object name -Like "*$ssepoch*" | Remove-AzureRmSnapshot -Force
    }
}