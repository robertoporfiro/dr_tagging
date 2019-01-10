# Common variables

variable "running_on_mac" {
  default = false
  description = "Switch to ensure Terraform uses the correct executable for powershell based on the operating system running it"
}

variable "rg_name" {
  description = "Resource group the automation account and everything assosciated to it will be created in"
}

variable "location" {
  default = "West Europe"
}

variable "subscription" {
  description = "Appears to be duplicate variable. ***NEEDS CLEANED UP***"
}

variable "certificate_thumbprint" {
  description = "Thumbprint from certificate that's attatched to the service principal for deployment"
}

variable "application_id" {
  description = "Application id of service princial"
}

variable "tenant_id" {
  description = "Tenant id of service principal"
}

# Automation variables

variable "aut_acc_name" {
  description = "Name for automation account"
}
variable "connection_certificate_name" {
  description = "Name of the connection certificate being used"
}

variable "connection_name" {
  description = "Name for the connection being created"
}

variable "connection_type_name" {
  description = "Name of the connection type e.g AzureServicePrincipal"
}

variable "pricing_tier" {
  description = "Pricing tier for the automation account"
}

variable "keyvault_name" {
  description = "Name of key vault where certificate is stored"
}

variable "automation_cert_name" {
  description = "Name of the certificate in the key vault"
}



variable "cert_password" {
  description = "Temp password used when creating the local version of the certificate and uploading to automation account"
}

# Modules Runbook Variables

variable "modules_script" {
  default = "../../runbookCode/modulesRunbook.ps1"
  description = "Points to the script location on system"
}

variable "modules_runbook_name" {
  default = "modules-runbook"
}



# Snapshot Runbook Variables

variable "snapshot_script" {
  default = "../../runbookCode/snapshotRunbook.ps1"
  description = "Points to the script location on system"
}

variable "schedule_name" {
  default = "test-schedule"
  description = "Name of the snapshot script schedule"
}

variable "snapshot_runbook_name" {
  default = "test-runbook"
  description = "Name to call the snapshot runbook"
}

###Check if dependencies still used###
variable "arm_temp_dependency_1" {
  default = "/resourceGroups"
  description = "First dependency string for ARM template"
}

variable "arm_temp_dependency_2" {
  default = "providers/Microsoft.Automation/automationAccounts"
  description = "Second dependency string for ARM template"
}

# failover Runbook Variables
variable "failover_script" {
  default = "../../runbookCode/re-instatevmRunbook.ps1"
  description = "Points to the failover script location on system"
}

variable "failover_runbook_name" {
  default = "failover_runbook"
}

# snapshot cleanup runbook variables
variable "snapshot_cleanup_script" {
  default = "../../runbookCode/cleanupRunbook.ps1"
  description = "Points to the snapshot cleanup script location on the system"
}

variable "snapshot_cleanup_runbook_name" {
  default = "snapshot-cleanup-runbook"
}

variable "snapshot_cleanup_schedule_name" {
  default = "snapshot-cleanup-schedule"
}

variable "snapshot_cleanup_schedule_start_time" {
  default = "1h"
  description = "Time after creation for the cleanup schedule to start"
}

#### Tagging variables ####
### These are required as ARM doesn't handle arrays being passed from terraform properly
variable "tags" {
  type = "map"
}

variable "armAutomationTag" {
}
variable "armBpcidTag" {
}
variable "armBusinessTag" {
}
variable "armCoreopsTag" {
}
variable "armMetricsTag" {
}
variable "armSecurityTag" {
}
variable "armTechnicalTag" {
}