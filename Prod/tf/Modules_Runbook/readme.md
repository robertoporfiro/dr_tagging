## Description

This TF creates the runbook and publishes it into an automation account. It also uses a local powershell provisioner to start the modules runbook after it has been created.

## Resources created

- Modules runbook
- null resource (Runs the modules runbook once after creation)

## Variables 

The variables for this module are passed though the Automation_Account module. These are</br>
- running_on_mac
- rg_name
- subscription_id
- location
- modules_script
- modules_runbook_name
- aut_acc_name

Descriptions for these variables can be found in the inputs.tf file.</br>
## Example Variables
```javascript
running_on_mac = true
rg_name = "test-rg"
location = "westeurope"
subscription_id = "453hhj54-jfs7-n534n5n-sdg722-fs1rj"
modules_script = "../../runbookCode/modulesRunbook.ps1"
aut_acc_name = "test-automation-account"
modules_runbook_name = "failover_runbook"
```