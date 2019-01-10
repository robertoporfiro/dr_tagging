## Description

This TF creates the runbook and publishes it into an automation account.

## Resources created

- Failover runbook

## Variables 

The variables for this module are passed though the Automation_Account module. These are</br>
- rg_name
- location
- subscription
- failover_script
- aut_acc_name
- failover_runbook_name

Descriptions for these variables can be found in the inputs.tf file.</br>
## Example Variables
```javascript
rg_name = "test-rg"
location = "westeurope"
subscription = "453hhj54-jfs7-n534n5n-sdg722-fs1rj"
failover_script = "../../runbookCode/re-instatevmRunbook.ps1"
aut_acc_name = "test-automation-account"
failover_runbook_name = "failover_runbook"
```