resource "azurerm_automation_runbook" "failover_runbook" {
  
  name                = "${var.failover_runbook_name}"
  location            = "${var.location}"
  resource_group_name = "${var.rg_name}"
  account_name        = "${var.aut_acc_name}"
  log_verbose         = "true"
  log_progress        = "true"
  description         = "Runbook that will trigger upon VM failure"
  runbook_type        = "PowerShell"

  publish_content_link {
    uri = "https://bitbucket.org/cloudreach/ais-dentsu-improvements/src/master/dr/Prod/snapshot.ps1"
  }

  content = "${data.local_file.failover_script.content}"

  tags = "${var.tags}"
}