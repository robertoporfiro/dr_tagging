locals {
   powershell_interpreter = "${var.running_on_mac ? "/usr/local/bin/pwsh" : "Powershell"}"
    short_name = "${substr("${var.webhook_name}",0,5)}"
}

resource "null_resource" "Action_Group_and_Webhook" {

  provisioner "local-exec" "Create-AGandWH" {
    command     = <<EOF

    if(Get-InstalledModule az -ErrorAction Ignore)
    {
      Write-Output "Az module detected, enabling aliases..."
      enable-azurermalias
    }
      Select-AzureRmSubscription -SubscriptionId ${var.subscription_id}
      Start-Sleep 5; $wh = New-AzureRmAutomationWebhook -Name ${var.webhook_name} -IsEnabled $True -ExpiryTime 10/2/2019 -RunbookName ${var.runbook_name} -ResourceGroup ${var.resource_group} -AutomationAccountName ${var.automation_account_name} -Force
      $receiver = New-AzureRmActionGroupReceiver -Name ${var.webhook_name} -WebhookReceiver -ServiceUri $wh.WebhookURI
      $la = Get-AzureRmLogicAppTriggerCallbackUrl -Name ${var.la_name} -ResourceGroupName ${var.la_resource_group} -TriggerName "manual"
      $receiver2 = New-AzureRmActionGroupReceiver -Name ${var.la_name} -WebhookReceiver -ServiceUri $la.value
      Set-AzureRmActionGroup -Name ${var.action_group_name} -ResourceGroupName ${var.resource_group} -ShortName ${local.short_name} -Receiver $receiver,$receiver2
    EOF
    interpreter = ["${local.powershell_interpreter}", "-Command"]
  }
}
