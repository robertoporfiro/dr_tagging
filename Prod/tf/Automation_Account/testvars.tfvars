# Common variables
rg_name = "bf-dr-rg"
location = "West Europe"

# Storage account variables
sa_name  = "bfdrsa"
cont_name = "images"

# Automation variables
snapshot_script = "../../snapshot.ps1"
# failover_script = "re-instatevm.ps1"

aut_acc_name  = "bf-dr-aac"
schedule_name = "bf-dr-schedule"
snapshot_runbook_name = "snapshot_runbook"
vm_failover_runbook_name = "failover_runbook"



