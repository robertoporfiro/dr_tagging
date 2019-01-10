resource "azurerm_automation_runbook" "snapshot_runbook" {
    
  name                = "${var.snapshot_runbook_name}"
  location            = "${var.location}"
  resource_group_name = "${var.rg_name}"
  account_name        = "${var.aut_acc_name}"
  log_verbose         = "true"
  log_progress        = "true"
  description         = "Runbook that will take VM snapshots every 60 minutes"
  runbook_type        = "PowerShell"

  publish_content_link {
    uri = "https://bitbucket.org/cloudreach/ais-dentsu-improvements/src/master/dr/Prod/snapshot.ps1"
  }

  content = "${data.local_file.snapshot_script.content}"

  tags = "${var.tags}"
}

#Cannot link schedule to runbook using terraform, need to use another way. 
#Possibly powershell or arm template.
resource "azurerm_automation_schedule" "schedule" {
    count = 4
  name                    = "${var.schedule_name}-${count.index}"
  resource_group_name     = "${var.rg_name}"
  automation_account_name = "${var.aut_acc_name}"
  frequency               = "Hour"
  interval                = 1

  #if not specified, start time defaults to 7 minutes in the future from the time the resource is created
  start_time = "${timeadd("${timestamp()}", "${format("%d", (var.snapshot_schedule_interval_minutes * count.index) + var.snapshot_schedule_interval_minutes)}m")}"
  description = "This schedules the runbook to run every 60 minutes"

  depends_on = ["azurerm_automation_runbook.snapshot_runbook"]
}

resource "random_uuid" "test" {
    count = 4
}

# The below ARM template is used to link the schedule to runbook.
resource "azurerm_template_deployment" "sch-temp" {
    count = 4
    
  name                = "${var.rg_name}-${"rb-sch-link"}-${count.index}"
  resource_group_name = "${var.rg_name}"

  template_body = <<DEPLOY

{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "autAccName": {
            "type": "String"
        },
        "jobScheduleName": {
            "type": "String"
        },
        "scheduleName": {
            "type": "String"
        },
        "runbookName": {
            "type": "String"
        },
        "resGroupName": {
            "type": "String"
        }

    },
    "resources": [
        {
            "type": "Microsoft.Automation/automationAccounts",
            "name": "[parameters('autAccName')]",
            "apiVersion": "2015-10-31",
            "location": "${var.location}",
            "properties": {
                "sku": {
                    "name": "Basic"
                }
            },
            "resources": [
                {
                    "type": "microsoft.automation/automationAccounts/jobSchedules",
                    "name": "[concat(parameters('autAccName'), '/', parameters('jobScheduleName'))]",
                    "apiVersion": "2015-10-31",
                    "location": "${var.location}",
                    "tags": {},
                    "properties": {
                        "schedule": {
                            "name": "[parameters('scheduleName')]"
                        },
                        "runbook": {
                            "name": "[parameters('runbookName')]"
                        }
                    },
                    "dependsOn": [
                        "[concat('Microsoft.Automation/automationAccounts/', parameters('autAccName'))]"
                    ]
                }
            ]
        }
    ]
}
DEPLOY

  #These parameters are passed to the ARM template's parameters block
  parameters {
    "autAccName"      = "${var.aut_acc_name}"
    "jobScheduleName" = "${element(random_uuid.test.*.result, count.index)}"
    "scheduleName"    = "${var.schedule_name}-${count.index}"
    "runbookName"     = "${var.snapshot_runbook_name}"
    "resGroupName"    = "${var.rg_name}"
  }

  deployment_mode = "Incremental"
  depends_on      = ["azurerm_automation_schedule.schedule", "azurerm_automation_runbook.snapshot_runbook"]
}