locals {
  powershell_interpreter = "${var.running_on_mac ? "/usr/local/bin/pwsh" : "Powershell"}"
}

resource "azurerm_automation_runbook" "modules_runbook" {
    
  name                = "${var.modules_runbook_name}"
  location            = "${var.location}"
  resource_group_name = "${var.rg_name}"
  account_name        = "${var.aut_acc_name}"
  log_verbose         = "true"
  log_progress        = "true"
  description         = "Runbook to install the required modules"
  runbook_type        = "PowerShell"

  publish_content_link {
    uri = "https://bitbucket.org/cloudreach/ais-dentsu-improvements/src/master/dr/Prod/snapshot.ps1"
  }

  content = "${data.local_file.modules_script.content}"

  tags = "${var.tags}"
}

resource "null_resource" "Start_Runbook" {
    provisioner "local-exec" "start_modules_runbook" {
    command     = "if(Get-InstalledModule az -ErrorAction Ignore){Write-Output \"Az module detected, enabling aliases...\";enable-azurermalias};Start-Sleep 5; Select-AzureRmSubscription -SubscriptionId ${var.subscription_id}; Start-AzureRmAutomationRunbook -AutomationAccountName ${var.aut_acc_name} -Name ${var.modules_runbook_name} -ResourceGroup ${var.rg_name} -Parameters @{\"ResourceGroupName\" = '${var.rg_name}';\"AutomationAccountName\"= '${var.aut_acc_name}'} " 
    interpreter = ["${local.powershell_interpreter}", "-Command"]
  }
  depends_on= ["azurerm_automation_runbook.modules_runbook"]
}
