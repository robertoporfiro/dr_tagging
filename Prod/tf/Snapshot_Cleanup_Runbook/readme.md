## Description

This TF creates the runbook and publishes it into an automation account. It also creates the schedule for the runbook to run.

## Resources created

- Snapshot Cleanup runbook
- Random uuid
- Schedule
- Schedule template deployment

## Variables 

The variables for this module are passed though the Automation_Account module. These are</br>
- running_on_mac
- rg_name
- location
- snapshot_cleanup_script
- snapshot_cleanup_runbook_name
- aut_acc_name
- snapshot_cleanup_schedule_name
- snapshot_cleanup_schedule_start_time

Descriptions for these variables can be found in the inputs.tf file.</br>
## Example Variables
```javascript
running_on_mac = true
rg_name = "test-rg"
location = "westeurope"
snapshot_cleanup_script = "../../runbookCode/cleanupRunbook.ps1"
aut_acc_name = "test-automation-account"
snapshot_cleanup_runbook_name = "failover_runbook"
snapshot_cleanup_schedule_name = "cleanup_schedule"
snapshot_cleanup_schedule_start_time = "1h"
```