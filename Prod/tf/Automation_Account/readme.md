## Description

This TF creates the automation account, uploads a certificate and creates a run as connection for authentication when running runbooks.</br>
It also creates and publishes the 4 runbooks for the automation account.</br>
Full diagram here 
https://www.lucidchart.com/documents/view/b7d92f98-c670-469d-80d8-012ec1e2c8f3/0

## Resources created

- Automation Account
- Template deployment for connection


## Variables 

The variables for this module are passed though the Automation_Account_Stack. They are listed below 
</br></br>

|                    Variable           |           Variable             |
|---------------------------------------|--------------------------------|
| running_on_mac                        | rg_name                        |
| snapshot_cleanup_schedule_name        | location                       |
| subscription                          | certificate_thumbprint         |
| application_id                        | tenant_id                      |
| aut_acc_name                          | connection_certificate_name    |
| connection_name                       | connection_type_name           |
| pricing_tier                          | keyvault_name                  |
| automation_cert_name                  | cert_password                  |
| modules_script                        | modules_runbook_name           |
| snapshot_script                       | schedule_name                  |
| snapshot_runbook_name                 | arm_temp_dependency_1          |
| arm_temp_dependency_2                 | failover_script                |
| failover_runbook_name                 | snapshot_cleanup_script        |
| snapshot_cleanup_runbook_name         | |
| snapshot_cleanup_scheddule_start_time |                                |
</br></br>
Descriptions for these variables can be found in the inputs.tf file.</br>

## Example Variables
```javascript

# Common Variables

    running_on_mac = true
    rg_name = "newdeployrg"
    location = "north europe"
    subscription_id = "7494274c-2e56-4d92-95a5-40071817c7f1"

# Automation Variables

    aut_acc_name = "rb-aa-la"
    pricing_tier = "Basic"
    certificate_thumbprint = "3FED2D7BBD644D9750F98DAD910E80E2A89AD6CF"
    application_id = "9fd3ae0f-3931-4864-a268-58158ae69c61"
    tenant_id = "40a4fe22-4e4e-48f9-b794-18a8109e47a3"
    connection_name = "AzureRunAsConnection"
    connection_type_name = "AzureServicePrincipal"
    connection_certificate_name = "AzureRunAsCertificate"
    cert_password = "pwd"
    keyvault_name = "automationacckv"
    automation_cert_name = "baseCert"

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

# Snapshot cleanup Module Variables

    snapshot_cleanup_script = "../../../runbookCode/cleanupRunbook.ps1"
    snapshot_cleanup_runbook_name = "cleanup_runbook"
    snapshot_cleanup_schedule_name = "snapshot-cleanup-daily-schedule-stacktest"
    snapshot_cleanup_schedule_start_time = "1h"
```