# Common Variables

    running_on_mac = true
    resource_group_name = "newdeployrg"
    location = "north europe"
    subscription = "7494274c-2e56-4d92-95a5-40071817c7f1"

# Automation Variables

    automation_account_name = "rb-aa-la"
    automation_account_pricing_tier = "Basic"
    certificate_thumbprint = "3FED2D7BBD644D9750F98DAD910E80E2A89AD6CF"
    application_id = "9fd3ae0f-3931-4864-a268-58158ae69c61"
    tenant_id = "40a4fe22-4e4e-48f9-b794-18a8109e47a3"
    connection_name = "AzureRunAsConnection"
    connection_type_name = "AzureServicePrincipal"
    connection_certificate_name = "AzureRunAsCertificate"
    cert_password = ""
    keyvault_name = "automationacckv"
    automation_cert_name = "baseCert"
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
    snapshot_cleanup_schedule_start_time = "12h"



    la_resource_group = "newdeployrg"
    eventhubConn = "conns9"
    logicAppName = "eightdeploy"
    connString = "Endpoint=sb://logicapptest02.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=sMP6PQOHWDt/YMZxUf26l6db+tHM+peVZ7gSewF2h10="
    eventhubname = "initaleh"