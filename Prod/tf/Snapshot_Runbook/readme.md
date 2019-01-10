## Description

This TF creates the runbook and publishes it into an automation account. It also creates 4 schedules, so the snapshot runbook runs every 15 minutes. This is because the minimum time
for a schedule is 1 hour so we need 4 to reach the 15 minute requirement.

## Resources created

- Snapshot runbook
- Random uuid x 4
- Schedule x 4
- Schedule template deployment x 4

## Variables 

The variables for this module are passed through the Automation_Account module. These are</br>
- rg_name
- location
- subscription
- snapshot_script
- aut_acc_name
- schedule_name
- snapshot_runbook_name
- snapshot_schedule_interval_minutes

Descriptions for these variables can be found in the inputs.tf file.</br>
## Example Variables
```javascript
rg_name = "test-rg"
location = "westeurope"
subscription = "453hhj54-jfs7-n534n5n-sdg722-fs1rj"
snapshot_script = "../../runbookCode/snapshotRunbook.ps1"
aut_acc_name = "test-automation-account"
snapshot_runbook_name = "failover_runbook"
schedule_name = "snapshot_schedule"
snapshot_schedule_interval_minutes = "15"
```