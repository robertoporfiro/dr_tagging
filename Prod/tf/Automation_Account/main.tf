locals {
  powershell_interpreter = "${var.running_on_mac ? "/usr/local/bin/pwsh" : "Powershell"}"
}

resource "azurerm_automation_account" "aut-acc" {
  
  name                = "${var.aut_acc_name}"
  location            = "${var.location}"
  resource_group_name = "${var.rg_name}"

  sku {
    name = "${var.pricing_tier}"
  }

  provisioner "local-exec" "upload_certificate" {
      
    command     = <<EOF

    if(Get-InstalledModule az -ErrorAction Ignore)
    {
        Write-Output "Az module detected, enabling aliases..."
        enable-azurermalias
    }

    Select-AzureRmSubscription -SubscriptionId "${var.subscription}"

    $Password = ConvertTo-SecureString -String "${var.cert_password}" -AsPlainText -Force 

    $kvSecret = Get-AzureKeyVaultSecret -VaultName "${var.keyvault_name}" -Name "${var.automation_cert_name}"
    $kvSecretBytes = [System.Convert]::FromBase64String($kvSecret.SecretValueText)
    $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
    $certCollection.Import($kvSecretBytes,$null,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
    $protectedCertificateBytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, "${var.cert_password}")
    $workingDir = (pwd)
    $pfxPath = "$workingDir/${var.automation_cert_name}.pfx"
    [System.IO.File]::WriteAllBytes($pfxPath, $protectedCertificateBytes)
    
    New-AzureRmAutomationCertificate -AutomationAccountName "${var.aut_acc_name}" -Name 'RunAsCertificate' -Path $pfxPath -Password $Password -ResourceGroupName "${var.rg_name}"
    
    rm $pfxPath

    EOF

    interpreter = ["${local.powershell_interpreter}", "-Command"]
  }
}

resource "azurerm_template_deployment" "connection-temp" {
  
  name                = "${var.rg_name}-${"connection-temp"}"
  resource_group_name = "${var.rg_name}"

  template_body = <<DEPLOY
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0",
    "parameters": {
        "accountName": {
            "type": "String"
        },
        "regionId": {
            "type": "String"
        },
        "pricingTier": {
            "type": "String"
        },
        "connectionName": {
            "type": "String"
        },
        "connectionTypeName": {
            "type": "String"
        },
        "connectionCertificateName": {
            "type": "String"
        },
        "subscriptionId": {
            "type": "String"
        },
        "certificateThumbprint": {
            "type": "String"
        },
        "applicationId": {
            "type": "String"
        },
        "tennantId": {
            "type": "String"
        },
        "automationTag": {
            "type": "String"
        },
        "bpcidTag": {
            "type": "String"
        },
        "businessTag": {
            "type": "String"
        },
        "coreopsTag": {
            "type": "String"
        },
        "metricsTag": {
            "type": "String"
        },
        "securityTag": {
            "type": "String"
        },
        "technicalTag": {
            "type": "String"
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Automation/automationAccounts",
            "name": "[parameters('accountName')]",
            "apiVersion": "2018-01-15",
            "location": "[parameters('regionId')]",
            "tags": {
                "automation":"[parameters('automationTag')]",
                "bpcid":"[parameters('bpcidTag')]",
                "business":"[parameters('businessTag')]",
                "coreops":"[parameters('coreopsTag')]",
                "metrics":"[parameters('metricsTag')]",
                "security":"[parameters('securityTag')]",
                "technical":"[parameters('technicalTag')]"
            },
            "properties": {
                "sku": {
                    "name": "[parameters('pricingTier')]"
                }
            },
            "resources": [
                {
                    "type": "connections",
                    "name": "[parameters('connectionName')]",
                    "apiVersion": "2018-01-15",
                    "location": "[parameters('regionId')]",
                    "tags": {},
                    "properties": {
                        "name": "[parameters('connectionName')]",
                        "description": "AzureServicePrincipal connection used to authenticate runbooks",
                        "isGlobal": false,
                        "connectionType": {
                            "name": "[parameters('connectionTypeName')]"
                        },
                        "fieldDefinitionValues": {
                            "SubscriptionID": "[parameters('subscriptionId')]",
                            "CertificateThumbprint": "[parameters('certificateThumbprint')]",
                            "ApplicationId": "[parameters('applicationId')]",
                            "TenantId": "[parameters('tennantId')]"
                        }
                    },
                    "dependsOn": [
                        "[concat('Microsoft.Automation/automationAccounts/', parameters('accountName'))]"
                    ]
                }
            ]
        }
    ],
    "outputs": {}
}
  DEPLOY

  #These parameters are passed to the ARM template's parameters block
  parameters {
    "accountName"               = "${var.aut_acc_name}"
    "pricingTier"               = "${var.pricing_tier}"
    "regionId"                  = "${var.location}"
    "connectionName"            = "${var.connection_name}"
    "connectionTypeName"        = "${var.connection_type_name}"
    "connectionCertificateName" = "${var.connection_certificate_name}"
    "subscriptionId"            = "${var.subscription}"
    "certificateThumbprint"     = "${var.certificate_thumbprint}"
    "applicationId"             = "${var.application_id}"
    "tennantId"                 = "${var.tenant_id}"
    "automationTag"             = "${var.armAutomationTag}"
    "bpcidTag"                  = "${var.armBpcidTag}"
    "businessTag"               = "${var.armBusinessTag}"
    "coreopsTag"                = "${var.armCoreopsTag}"
    "metricsTag"                = "${var.armMetricsTag}"
    "securityTag"               = "${var.armSecurityTag}"
    "technicalTag"              = "${var.armTechnicalTag}"
    }

  deployment_mode = "Incremental"
  depends_on      = ["azurerm_automation_account.aut-acc"]
}

# Module Calls have to happen within the Automation_Account module; there is no way to map dependencies otherwise.

module "Modules_Runbook" {
    source = "../Modules_Runbook"
    running_on_mac = "${var.running_on_mac}"
    subscription_id = "${var.subscription}"
    rg_name = "${var.rg_name}"
    location = "${var.location}"

    aut_acc_name = "${azurerm_automation_account.aut-acc.name}" 
    modules_script = "${var.modules_script}"
    modules_runbook_name = "${var.modules_runbook_name}"
    tags = "${var.tags}"
}

module "Snapshot_Runbook" {
    
    source = "../Snapshot_Runbook"
    rg_name = "${var.rg_name}"
    location = "${var.location}"
    subscription = "${var.subscription}"

    aut_acc_name = "${azurerm_automation_account.aut-acc.name}"
    schedule_name = "${var.schedule_name}"
    snapshot_script = "${var.snapshot_script}"
    snapshot_runbook_name = "${var.snapshot_runbook_name}"
    tags = "${var.tags}"
}

module "Failover_Runbook" {
    
    source = "../Failover_Runbook"
    rg_name = "${var.rg_name}"
    location = "${var.location}"
    subscription = "${var.subscription}"

    aut_acc_name = "${azurerm_automation_account.aut-acc.name}"
    failover_script = "${var.failover_script}"
    failover_runbook_name = "${var.failover_runbook_name}"
    tags = "${var.tags}"
}

module "Snapshot_Cleanup_Module" {
    source = "../Snapshot_Cleanup_Runbook"
    rg_name = "${var.rg_name}"
    location = "${var.location}"
    aut_acc_name = "${azurerm_automation_account.aut-acc.name}"

    snapshot_cleanup_script = "${var.snapshot_cleanup_script}"
    snapshot_cleanup_runbook_name = "${var.snapshot_cleanup_runbook_name}"
    snapshot_cleanup_schedule_name = "${var.snapshot_cleanup_schedule_name}"
    snapshot_cleanup_schedule_start_time = "${var.snapshot_cleanup_schedule_start_time}"
    tags = "${var.tags}"

}