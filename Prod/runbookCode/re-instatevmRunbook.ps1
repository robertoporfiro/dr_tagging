[OutputType("PSAzureOperationResponse")]

param
(
    [Parameter (Mandatory=$false)]
    [object] $WebhookData
)

#region Auto-Generated DO NOT EDIT
$ErrorActionPreference = "stop"

if ($WebhookData)
{
   # Get the data object from WebhookData.
    $WebhookBody = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)
    $WebhookName = $WebhookData.WebhookName
    $AlertContext = [object] ($WebhookBody.data).context
    $ResourceName = $AlertContext.resourceName
    $ResourceType = $AlertContext.resourceType
    $ResourceGroupName = $AlertContext.resourceGroupName
    $SubId = $AlertContext.subscriptionId
    $ResourceName = $AlertContext.resourceName
    Write-Verbose "resourceType: $ResourceType, resourceName: $ResourceName, resourceGroupName: $ResourceGroupName, subscriptionId: $SubId" -Verbose

    $ConnectionAssetName = "AzureRunAsConnection"
    $Conn = Get-AutomationConnection -Name $ConnectionAssetName
    if ($Conn -eq $null)
    {
        throw "Could not retrieve connection asset: $ConnectionAssetName. Check that this asset exists in the Automation account."
    }
    Write-Output "Authenticating to Azure with service principal and setting subscription to $SubId." -Verbose
    Connect-AzureRmAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint | Write-Verbose
    Set-AzureRmContext -SubscriptionId $SubId -ErrorAction Stop | Write-Verbose
}
else {
   # Error
    Write-Error "This runbook is meant to be started from an Azure alert webhook only."
}
#endregion

$currJobId = $PsPrivateMetaData.JobId.Guid
Write-Verbose "Current Job ID: $currJobId"

# Initiliase the function to retrieve current automation account information
function Get-CurrentAutomationAccount () {

    Param (
        $Runbook,
        $currJobId
    )

    $MatchingRunbooks = (Get-AzureRmResource -ResourceType Microsoft.Automation/automationAccounts/runbooks) | where {$_.Name -match "$Runbook"}
    


    foreach($MatchingRunbook in $MatchingRunbooks)
    {
        $automationAccountName = $MatchingRunbook.Name.Split("/")[0]

        $jobs = Get-AzureRmAutomationJob -ResourceGroupName $MatchingRunbook.ResourceGroupName -AutomationAccountName $automationAccountName -Status Running

        Foreach($job in $jobs)
        {
            if($job.JobId -eq $currJobId)
            {
                Write-Output 'Found the current automation account details, use $CurrentAutomationAccount to access its properties.'
                return (Get-AzureRmAutomationAccount -ResourceGroupName $MatchingRunbook.ResourceGroupName -AutomationAccountName $automationAccountName)
            }
        }
    }
}

# Call the function to get current automation account information, filtering based on runbook name.

Write-Output "Getting information about the current automation account..."

try{
$CurrentAutomationAccount = Get-CurrentAutomationAccount -currJobId $currJobId -Runbook "failover_runbook"

$CurrentAutomationAccountName = $CurrentAutomationAccount.AutomationAccountName
$CurrentAutomationAccounutResourceGroup =  $CurrentAutomationAccount.ResourceGroupName

Write-Output "   --> This is $CurrentAutomationAccountName in resource group $CurrentAutomationAccounutResourceGroup"
}
catch {
    Write-error "Failed to get current automation account information. Check the deployed failover runbook is called 'failover_runbook'"
}

#Get-AzureRmAutomationJob only returns the input parameters when JOB id's includes
$jobIds = (Get-AzureRmAutomationJob -ResourceGroupName $CurrentAutomationAccounutResourceGroup -RunbookName "failover_runbook" -AutomationAccountName $CurrentAutomationAccountName| where {($_.StartTime -gt ((Get-Date).AddHours(-1))) -and ($_.JobId -ne $currJobId)}).JobId
if($jobIds.count -gt 0){
    foreach($jobid in $jobIds){
        $job = Get-AzureRmAutomationJob -ResourceGroupName $CurrentAutomationAccounutResourceGroup -AutomationAccountName $CurrentAutomationAccountName -JobId $jobid
        $vmInJob = ($job.JobParameters.webhookData.RequestBody | ConvertFrom-Json).data.context.resourceName

        if($vmInJob -eq $ResourceName){
            switch ($job.Status){
                "Completed"{
                    Write-Output "$vmInJob has already failed over, exiting..."
                    Exit 0
                    break
                }
                "Running"{
                    Write-Output "Failover job for $vmInJob in progress"
                    Exit 0
                    break
                }
                Default{
                    Write-Output "Starting VM failover..."
                }
            }
        }
    }
}

$agval = (Get-AzureRmActionGroup -ResourceGroupName $ResourceGroupName -WarningAction Ignore | Where-Object {$_.WebhookReceivers.name -eq $WebhookName}).Name


### json for enroling a VM in monitoring
$armjson =@' 
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {},
    "resources": [
        {
            "name": "ALERTNAME",
            "type": "Microsoft.Insights/metricAlerts",
            "location": "global",
            "apiVersion": "2018-03-01",
            "tags": {},
            "properties": {
                "description": "Auto-failover alert",
                "severity": "3",
                "enabled": "ENVARVAL",
                "scopes": ["VMID01"],
                "evaluationFrequency":"PT1M",
                "windowSize": "PT5M",
                "criteria": {
                    "odata.type": "Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria",
                    "allOf": [
                        {
                            "name" : "1st criterion",
                            "metricName": "Network Out",
                            "dimensions":[],
                            "operator": "LessThan",
                            "threshold" : "1000",
                            "timeAggregation": "Total"
                        }
                    ]
                },
                "actions": [
                    {
                        "actionGroupId": "AGID01"
                    }
                ]
            }
        }
    ]
}
'@

#name of the faild VM
$vmName = $ResourceName
$vmRG = $ResourceGroupName
$alertname = ($AlertContext.Name)

### disable old VM monitoring
Write-Output "Getting VM details for vm $vmName and action group $agval in resource group $vmRG..."

try{
    $oldVM = Get-AzureRmVM -name $vmName -resourceGroupName $vmRG

    $agid= Get-AzureRmActionGroup | where {$_.name -like "$agval"}
    $agid = $agid | Select-Object -First 1 
    $agname = $agid.id

    Write-Output "   --> Done"
}
catch{
    Write-Error "Failed to retrieve information about VM $vmName or action group $agval"
}

$scopearm = $armjson -replace "VMID01",$oldVM.id
$scopearm = $scopearm -replace "ENVARVAL", "false"
$finalarm = $scopearm -replace "AGID01",$agname
$finalarm = $finalarm -replace "ALERTNAME", $alertname

echo $finalarm > afalertdisable.json


Write-Output "# REMOVING VM $vmName FROM ACTION GROUP $agval"


try{
    $afalertdisable = New-AzureRmResourceGroupDeployment -Name "afalertdisable-$vmName" `
    -ResourceGroupName $vmRG `
    -TemplateFile ./afalertdisable.json

    Write-Output "   --> VM $vmName has successfully been removed from monitoring alert $alertname and action group $agval"
}
catch{
    Write-Error "Failed to disable alert" $AlertContext.Name "for VM $vmName"
}

Write-Verbose "Results of ARM deployment to disable the alert: $afalertdisable"

### get the latest disks for the VM###
#Get all of the OS disks snapshots for that VM and then order them decending (newest in position 0)

Write-Output "Getting latest os disk snapshot for VM $vmName"
try{
    $allVmOsDisks = Get-AzureRmSnapshot | `
        Where-Object name -Like *"$vmName-OSdisk-"* | `
        Sort-Object name –Descending

   #select only the most recent snapshot (position 0)
    $lastestDisk = $allVmOsDisks[0]

   #parse out the seconds since epoch
    $ssEpoch = $lastestDisk.name.Substring($lastestDisk.name.Length -16)
   #get all of the disks (data and OS) for that vm at that time
    $currentDisks = Get-AzureRmSnapshot | `
        Where-Object name -Like *"$vmName"* | `
        Where-Object name -Like *"$ssEpoch"*
    $currentDiskName = $currentDisks.Name
    Write-Output "   --> The latests os disk snapshot for VM $vmName is $currentDiskName"
}
catch{
    Write-error "Could not retrieve latest os disk snapshot for VM $vmName. Ensure snapshots exist and were taken using the snapshot_runbook."
}

### create the new name. if it has failed over before, remove the numbers val, parse to int and increment, otherwise ad 'dr01'
if ($vmName -like "*-dr*"){
    $updateName = ($vmName.Substring(0, $vmName.Length - 2)) + (([int]$vmName.Substring($vmName.Length -2)) + 1).ToString("00")
}else{
    $updateName = "$vmName-dr01"
}

### create a new NIC, attach it to the old VM, remove the original NIC###
#dynamically get VM and subnet info
Write-Output "Getting $vmName's NIC configuration..."
try{
    $oldNic = Get-AzureRmNetworkInterface | `
        Where-Object { $_.VirtualMachine.id -eq $oldVM.id}
    $subnet = $oldNic.IpConfigurations.subnet.id
   # appeand nic01 to the vm name
    $newNicName = "$updateName" + "nic01"
    $location = $oldVM.location
    Write-Output "   --> Successfully retrieved NIC configuration for $vmName"
}
catch{
    Write-Error "Failed to retrieve NIC configuration for VM $vmName"
}

#create a new nic for the old VM

Write-Output "# CREATING A NEW NETWORK INTERFACE CARD"

try{
        $newIpConfig = New-AzureRmNetworkInterfaceIpConfig -Name "IPConfig1" `
            -PrivateIpAddressVersion IPv4 -SubnetId $subnet

        $newNic = New-AzureRmNetworkInterface -Name $newNicName `
            -ResourceGroupName $vmRG `
            -Location $location `
            -IpConfiguration $newIpConfig `
            -Force

        Write-Output "   --> Successfully created NIC $newNicName in resource group $vmRG"
}
catch{
    Write-error "Failed to create new network interface card."
}


Write-Output "# ASSIGNING NEW NIC TO FAILED VM"

#check old vm is shut down
try{
    Write-verbose (Stop-AzureRmVM -Name $vmName -resourceGroupName $vmRG -force)

   #associate new nic to old VM (on the object)
    Write-verbose (Add-AzureRmVMNetworkInterface -VM $oldVM -Id $newNic.id)
   #make the newly added nic the primary (on the object)
    $oldVM.NetworkProfile.NetworkInterfaces.Item(1).primary = $true
    $oldVmOs = $oldVM.StorageProfile.OsDisk.OsType
   #remove the old nic from the VM object
    Write-verbose (remove-AzureRmVMNetworkInterface -VM $oldVM -Id $oldNic.id)
   #write the updated object to azure
    write-verbose (Update-AzureRmVM -ResourceGroupName $vmRG -VM $oldVM)

    Write-Output "   --> Successfully assigned $newNicName to $($oldVm.name)"
}
Catch{
    Write-Error "Failed to assign $newNicName to $($oldVm.name)"
}

### create the new VM###
# set up variables for new VM 
# appeand -OSdisk to the vm name


Write-Output "# CREATING OS DISK FOR NEW VM.."


try{
    $osDiskName = "$updateName" + "-OSdisk"
    $vmSize = $oldVM.HardwareProfile.VmSize
    $storageAccountType = "Standard_LRS"
    $newVmName = "$updateName"

   ### this doesnt work yet
    $vmConfig = New-AzureRmVMConfig -VMName $newVmName -VMSize $vmSize
   #change this id to the nic of the old vm's id
    $vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $oldNic.id

   #create the configuration for the disk (source is the snapshot)
    $diskConf = New-AzureRmDiskConfig -AccountType $storageAccountType `
        -Location   $lastestDisk.Location `
        -SourceResourceId $lastestDisk.Id `
        -CreateOption Copy `
        -OsType $oldVmOs

   # create the new os disk from the config
    $osDisk = New-AzureRmDisk -Disk $diskConf `
        -ResourceGroupName $vmRG `
        -DiskName $osDiskName


   #attach the os disk to the vm VM
    if(($oldVmOs -eq "Linux") -or ($oldVmOs -eq "Windows")){
        switch ($oldVmOs) {
            "Linux" {
                Write-verbose (Set-AzureRmVMOSDisk -VM $vm `
                                    -ManagedDiskId $osDisk.Id `
                                    -StorageAccountType $storageAccountType `
                                    -DiskSizeInGB 128 `
                                    -CreateOption Attach -Linux)
            }
            "Windows" {
                Write-Verbose (Set-AzureRmVMOSDisk -VM $vm `
                                    -ManagedDiskId $osDisk.Id `
                                    -StorageAccountType $storageAccountType `
                                    -DiskSizeInGB 128 `
                                    -CreateOption Attach -Windows)

                Write-Output "OSType for new disk set to Windows"
            }
        }
    }
    else{
        Write-Error "OsType should be either Linux or Windows"
    }
    Write-Output "   --> Successfully created $osDiskName with OSType $oldVmOs"
}
Catch{
    Write-Error "Failed to create disk $osDiskName for new VM."
}

Write-Output "# CREATING NEW VM $newVmName"
try{
    $vm = Set-AzureRmVMBootDiagnostics -VM $vm -disable

    #add the plan to the new vm
    if ($oldVM.plan.product -eq "cisco-meraki-vmx100"){
        Set-AzureRmVMPlan -VM $vm -Publisher "cisco" -Product "cisco-meraki-vmx100" -name "vmx100"
    }
    #Create the new VM
    Write-verbose (New-AzureRmVM -ResourceGroupName $vmRG -Location $location -VM $vm)
    Write-output "   --> Successfully created $newVmName in resource group $vmRG"
}
catch{
    Write-Output "Failed to create new VM $newVmName in $vmRg"
}

Write-Output "RECREATING DATA DISKS FOR $newVmName"
try{
    $newCreatedVm = Get-AzureRmVM -resourceGroupName $vmRG -name $vm.name

    ### This will re-instate data disks###
    #this will get the list off all data disks
    $dataDisks = Get-AzureRmSnapshot | `
        Where-Object name -Like *"$vmName"* | `
        Where-Object name -Like *"$ssEpoch"* | `
        Where-Object name -NotLike *"-OSdisk-"* | `
        Sort-Object name

    #type of storage
    $storageType = 'Standard_LRS'
    #initalise counter for lun
    $lun = 0

    if($dataDisks){
        foreach($dataDisk in $dataDisks){
            #create the config
                $dataDiskConfig = New-AzureRmDiskConfig -AccountType $storageType `
                    -Location   $dataDisk.Location `
                    -SourceResourceId $dataDisk.Id `
                    -CreateOption Copy
                
            #dynamically create the disk name
            # appeand datadisk and the lun to the vm name
                $diskName = "$updateName-datadisk_$lun"
                
            #create the new disk and store the output (to add it to vm later)
                $copyDisk = New-AzureRmDisk -Disk $dataDiskConfig -ResourceGroupName $vmRG -DiskName $diskName
            
            #add data disk to vm
                Write-verbose (Add-AzureRmVMDataDisk -VM $newCreatedVm -ManagedDiskId $copyDisk.id -lun $lun -createoption attach)
            #increment lun for next disk
                $lun = $lun + 1
            }  
            Write-verbose (Update-AzureRmVM -resourceGroupName $vmRG -VM $newCreatedVm)
            Write-Output "   --> Successfully recreated and attached the following data disks: " $dataDisks.Name      
    }
    else{
        Write-Output "   --> There were no data disks associated with $($oldVM.name)"
    }
}
catch {
    Write-Error "Failed to recreate the following data disks: " $dataDisks.Name
}

Write-Output "Ensuring old NIC has moved over to new VM"
$newVmName = $newCreatedVm.name
### this section will ensure that the NIC has moved over
$newVmObj = Get-AzureRmVM -resourceGroupName $vmRG -VM $newCreatedVm.name
if ($newVmObj.NetworkProfile.NetworkInterfaces.id -eq $oldNic.id){
   Write-Output "   --> Old NIC has successfully been associated with VM $newVmName"
}else{
    Write-Output "   --> Old NIC was not moved over to $newVmName, attempting again..."

    try{
        $oldNicObj = Get-AzureRmNetworkInterface | where {$_.id -eq $oldVM.NetworkProfile.NetworkInterfaces.id}
        $corIpVal = $oldNicObj | Get-AzureRmNetworkInterfaceIpConfig    
        $oldNicObj.IpConfigurations[0].PrivateIpAllocationMethod = "Dynamic"
        Write-verbose (Set-AzureRmNetworkInterface -NetworkInterface $oldNicObj)

        $newVmNicObj = Get-AzureRmNetworkInterface | where {$_.id -eq $newCreatedVm.NetworkProfile.NetworkInterfaces.id}
        $newVmNicObj.IpConfigurations[0].PrivateIpAddress = $corIpVal.PrivateIpAddress
        Write-verbose (Set-AzureRmNetworkInterface -NetworkInterface $newVmNicObj)
        Write-Output "         --> Old NIC has now been moved over to $newVmName"
    }
    catch{
        Write-Error "Failed to moved the old NIC over $newVmName"
    }
}


### this will create the inital snapshot of the VM###
#store date as var for use with snapshot names

Write-Output "# TAKING INITIAL VM SNAPSHOT"

try{
    $dateVar ="$((Get-Date -UFormat "%s.").Substring(0,11))$(Get-Date -Format "fffff")"

    #create os disk snapshot name
    $OsSnapshotName= $newVmObj.name + "-OSdisk-" + $dateVar

    #create a snapshot config with the managed disk from the VM os disk
    $osDiskSnapshot = New-AzureRmSnapshotConfig `
        -SourceUri $newVmObj.StorageProfile.OsDisk.ManagedDisk.Id `
        -Location $newVmObj.location `
        -CreateOption copy `
        -SkuName Standard_ZRS

    #create the actual snapshot of the os disk
    Write-verbose (New-AzureRmSnapshot `
                    -Snapshot $OsDiskSnapshot `
                    -SnapshotName $OsSnapshotName `
                    -ResourceGroupName $newVmObj.ResourceGroupName)

    #get other data disks if attatched, could be list if more than 1
    $dataDisks = $newVmObj.StorageProfile.DataDisks

    foreach ($dataDisk in $dataDisks){
        $dataDiskSnapshotName = $newVmObj.name + "-" + $dataDisk.name + "-" + $dateVar
    #Snapshot config for each data disk
        $dataDiskSnapshot = New-AzureRmSnapshotConfig `
            -SourceUri $dataDisk.ManagedDisk.Id `
            -Location $newVmObj.location `
            -CreateOption copy `
            -SkuName Standard_ZRS

    #create actual snapshots
        Write-verbose (New-AzureRmSnapshot `
                        -Snapshot $dataDiskSnapshot `
                        -SnapshotName $dataDiskSnapshotName `
                        -ResourceGroupName $newVmObj.ResourceGroupName)
    }
    Write-Output "   --> Successfully took initial disk snapshot(s) for $newVmName"
}
catch{
    Write-Error "Failed to take initial snapshot(s) for $newVmName"
}


### enrol the new VM in monitoring
#$agid= Get-AzureRmActionGroup | where {$_.name -like "$agname"}
$scopearm = $armjson -replace "VMID01",$newVmObj.id
$scopearm = $scopearm -replace "ENVARVAL", "true"
$finalarm = $scopearm -replace "AGID01",$agname
$finalarm = $finalarm -replace "ALERTNAME", $alertname

echo $finalarm > addalert.json

Write-Output "Pausing for 5 minutes to ensure VM is ready to be monitored." # 5 minutes is the threshold at which we were no longer having issues with the new VM failing over instantly.
Start-sleep -s 300

Write-Output "# CREATING ALERT $alertname TIED TO ACTION GROUP $agval FOR VM $newVmName"
try{
    $afalertdeploy = New-AzureRmResourceGroupDeployment -Name "afalertdeploy-$newVmName" `
    -ResourceGroupName $vmRG `
    -TemplateFile ./addalert.json
    Write-Output "   --> Successfully enrolled VM in monitoring."
}
catch{
    Write-error "Failed to deploy ARM to enable the alert $alertname on $newVmName"
}

Write-Verbose "Results of running the ARM to enable the alert: $afalertdeploy"

Write-Output "###################################################################################################################################"
Write-Output "                                                      FAILOVER COMPLETE"
Write-Output "###################################################################################################################################"