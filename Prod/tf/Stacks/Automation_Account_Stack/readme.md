## Description

This module creates the automation account, runbooks and related resources as per diagram below. 

![alt text](https://www.lucidchart.com/publicSegments/view/5b993d6d-fa81-4812-b020-58cfa249e82f/image.png "Automation_Acccount_Stack calls")
See https://www.lucidchart.com/documents/edit/4d23f0de-3950-4827-b3b8-acbdeb444bef/0 for full diagram.

## Variable Description

See input.tf file for variable description.

## Example Variables
```javascript

# Common Variables

    running_on_mac = true
    resource_group_name = "bf-dr-dan"
    location = "north europe"
    subscription = "23666e70-4091-4ab9-929c-9ef08446f52e"

# Automation Variables

    automation_account_name = "bf-aac-alias"
    automation_account_pricing_tier = "Basic"
    certificate_thumbprint = "02EF3F676C8143BC01E9F09D0534C6DDA778C9D6"
    application_id = "d0cd59fb-a575-4c28-8574-6c37f53bd977"
    tenant_id = "152e4c75-3657-4284-bb2c-0d825873d72b"
    connection_name = "AzureRunAsConnection"
    connection_type_name = "AzureServicePrincipal"
    connection_certificate_name = "AzureRunAsCertificate"
    cert_password = "pwd"
    keyvault_name = "bf-keyvault"
    automation_cert_name = "AutomationAccountCert"
    action_group_name = "ActionGroup_alias"
    webhook_name = "webhook_alias"

# Modules Runbook Variables

    modules_script = "../../../runbookCode/modulesRunbook.ps1"
    modules_runbook_name = "modules_runbook"

# Snapshot Module Variables
    # start_time
    schedule_name = "snapshot_runbook_schedule"
    snapshot_script = "../../../runbookCode/snapshotRunbook.ps1"
    snapshot_runbook_name = "snapshot_runbook"

# Failover Module Variables

    failover_script = "../../../runbookCode/re-instatevmRunbook.ps1"
    failover_runbook_name = "failover_runbook"

# Snapshot cleanup module Variables

    snapshot_cleanup_script = "../../../runbookCode/cleanupRunbook.ps1"
    snapshot_cleanup_runbook_name = "cleanup_runbook"
    snapshot_cleanup_schedule_name = "snapshot-cleanup-daily-schedule-stacktest"
    snapshot_cleanup_schedule_start_time = "1h"
```
