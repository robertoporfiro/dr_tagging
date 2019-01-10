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

foreach($vmName in $vmList){
    #store date as var for use with snapshot names
    Select-AzureRmSubscription -SubscriptionId $vmName.subscriptionId
    $dateVar = "$((Get-Date -UFormat "%s.").Substring(0,11))$(Get-Date -Format "fffff")"

    $rgVar = Get-azureRmResourceGroup -name $vmName.resourceGroup
    $uri = $rgVar.ResourceId + "/providers/Microsoft.Compute/virtualMachines/" + $vmName.name

    $vmObjs= Get-AzureRmVM | Where-Object { $_.id -like "$uri*"}

    if ($vmObjs.Length -eq "1"){
        $vm = Get-AzureRmVm  -name $vmObjs.name -ResourceGroupName $vmObjs.resourceGroupName
    }elseif ($vmObjs.Length -gt "1"){
        $vmObjs = $vmObjs | Sort-Object -Property Name -Descending
        $vm = Get-AzureRmVm  -name $vmObjs[0].name -ResourceGroupName $vmObjs[0].resourceGroupName
    }else{
        #come back to what we should do here
        echo "pass - error"
    }

    #create os disk snapshot name
    $OsSnapshotName= $vm.name + "-OSdisk-" + $dateVar

    #create a snapshot config with the managed disk from the VM os disk
    $osDiskSnapshot = New-AzureRmSnapshotConfig `
        -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id `
        -Location $vm.location `
        -CreateOption copy `
        -SkuName Standard_ZRS

    #create the actual snapshot of the os disk
    New-AzureRmSnapshot `
        -Snapshot $OsDiskSnapshot `
        -SnapshotName $OsSnapshotName `
        -ResourceGroupName $vm.ResourceGroupName

    #get other data disks if attatched, could be list if more than 1
    $dataDisks = (Get-AzureRmVm -name $vm.name `
    -ResourceGroupName $vm.ResourceGroupName).StorageProfile.DataDisks

    foreach ($dataDisk in $dataDisks){
        $dataDiskSnapshotName = $vm.name + "-" + $dataDisk.name + "-" + $dateVar
        #Snapshot config for each data disk
        $dataDiskSnapshot = New-AzureRmSnapshotConfig `
            -SourceUri $dataDisk.ManagedDisk.Id `
            -Location $vm.location `
            -CreateOption copy `
            -SkuName Standard_ZRS

        #create actual snapshots
        New-AzureRmSnapshot `
            -Snapshot $dataDiskSnapshot `
            -SnapshotName $dataDiskSnapshotName `
            -ResourceGroupName $vm.ResourceGroupName
    }
}