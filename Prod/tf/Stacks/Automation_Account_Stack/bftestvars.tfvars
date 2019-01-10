# Common Variables

    running_on_mac = true
    resource_group_name = "bf-dr-dan-eu"
    location = "north europe"
    subscription = "23666e70-4091-4ab9-929c-9ef08446f52e"

# Automation Variables
    automation_account_name = "bf-automation-account"
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
    action_group_name = "ActionGroup_0801"
    webhook_name = "webhook_0801"

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
    failover_runbook_name = "failover_runbook" # This should be left as 'failover_runbook' as there are dependencies on this name

# Snapshot cleanup module Variables

    snapshot_cleanup_script = "../../../runbookCode/cleanupRunbook.ps1"
    snapshot_cleanup_runbook_name = "cleanup_runbook"
    snapshot_cleanup_schedule_name = "snapshot-cleanup-daily-schedule-stacktest"
    snapshot_cleanup_schedule_start_time = "1h"

# CoreOpsLink Variables

    la_resource_group = "bf-dr-dan-eu"
    eventhubConn = "conns9"
    logicAppName = "eightdeploy"
    connString = "Endpoint=sb://logicapptest02.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=sMP6PQOHWDt/YMZxUf26l6db+tHM+peVZ7gSewF2h10="
    eventhubname = "initaleh"


