param(
    [Parameter(Mandatory=$false)]
    [String] $ResourceGroupName = "bf-dr-rg",

    [Parameter(Mandatory=$false)]
    [String] $AutomationAccountName = "bf-aac-stack118",

    $Dependencies = ("Azurerm.profile"),

    $module1 = @{
        name = "AzureRM.Resources"
    },
    $module2 = @{
        name = "AzureRM.Compute"
    },
    $module3 = @{
        name = "AzureRM.Network"
        version = "6.8.0"
    },    
    $module4 = @{
        name = "AzureRM.Insights"
    },
    $module5 = @{
        name = "AzureRM.Automation"
    },
    [System.Collections.ArrayList]
    $moduleList = @($module1,$module2,$module3,$module4,$module5)
)

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$stopwatch =  [system.diagnostics.stopwatch]::StartNew()

$stopwatch.Start()


foreach($dependency in $Dependencies)
{
    $ModuleContentUrl = "https://www.powershellgallery.com/api/v2/package/$dependency"
    New-AzureRmAutomationModule -Name $dependency -ContentLink $ModuleContentUrl -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName

    Write-Output "Installing dependency: $dependency"
    $i = 1

    Start-Sleep 2
    while ((Get-AzureRmAutomationModule -Name $dependency -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName).ProvisioningState -ne "Succeeded")
    {
        ("===" * $i)
        Start-Sleep -Seconds 5
        $i++
    }
    Write-Output "$dependency successfully installed!"
}

foreach($module in $moduleList)
{
    $ModuleContentUrl = "https://www.powershellgallery.com/api/v2/package/" + $module.name+ "/" + $module.version

    Write-Output "Installing" $module.name
    New-AzureRmAutomationModule -Name $module.name -ContentLink $ModuleContentUrl -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName
    Write-Output "Installing module: " $module.name
    $i = 1

    Start-Sleep 2
    while ((Get-AzureRmAutomationModule -Name $module.name -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName).ProvisioningState -ne "Succeeded")
    {
        ("===" * $i)
        Start-Sleep -Seconds 5
        $i++
    }
    Write-Output $module.name "successfully installed!"
}

$stopwatch.stop()
$stopwatch.Elapsed