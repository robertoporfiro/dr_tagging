# ------------------------------------------------------------------
#           Common Variables
# ------------------------------------------------------------------
variable "running_on_mac" {
    description = "Switch to ensure Terraform uses the correct executable for powershell based on the operating system running it."
    default = false
}

variable "resource_group_name" {
    description = "The name of the resource group to deploy to."
}

variable "location" {
    description = "The location of the resource group to deploy to."
}

variable "subscription" {
    description = "The subscription to deploy to."
}

# ------------------------------------------------------------------
#           Automation Variables
# ------------------------------------------------------------------
variable "automation_account_name" {
    description = "The name of the automation account to create"
}

variable "automation_account_pricing_tier" {
    description = "The pricing tier of the automation account: basic or free"
}

variable "certificate_thumbprint" {
  description = "The thumbprint of the certificate associated with the service principal used for the deployment. See readme.md file for more information"
}

variable "application_id" {
  description = "The application ID of the service principal used for deployment"
}

variable "tenant_id" {
  description = "The tenant id against which the subscription is registered."
}
variable "connection_name" {
description = "The name of the connection that will be created in the automation account."
}

variable "connection_type_name" {
  description = "The type of connection to use with the automation account (AzureServicePrincipal, Basic...)"
}

variable "connection_certificate_name" {
  description = "The name of the certificate as it will appear in the automation account."
}

variable "cert_password" {
  description = "The password for the certificate .pfx file"
}

variable "keyvault_name" {
  description = "The name of the keyvault to retrieve the certificate from. This assumes the certificate is saved in the keyvault as a Certificate asset."
}
variable "automation_cert_name" {
  description ="The name of the certificate to be retrieved from the keyvault."
}


variable "action_group_name" {
  description = "The name of the action group to be created"
}

variable "webhook_name" {
  description = "The name of the webhook to be created (should be at least 6 characters)"
}



# ------------------------------------------------------------------
#           Module Variables
# ------------------------------------------------------------------

# Module Update

variable "modules_script" {
  description = "The full path to the relevant script"
}

variable "modules_runbook_name" {
  description = "The name of the runbook as it will appear in the automation account."
}



# Snapshot Module

variable "schedule_name" {
  description = "The name of the schedule to be created and applied to runbook."
}

variable "snapshot_script" {
  description = "The full path to the relevant script"
}
variable "snapshot_runbook_name" {
  description = "The name of the runbook as it will appear in the automation account."
}

# Failover Module

variable "failover_script" {
  description = "The full path to the relevant script"
}

variable "failover_runbook_name" {
  description = "The name of the runbook as it will appear in the automation account."
}

# Snapshot Cleanup Module
variable "snapshot_cleanup_script" {
    description = "The full path to the relevant script"
}

variable "snapshot_cleanup_runbook_name" {
    description = "The name of the runbook as it will appear in the automation account."
}

variable "snapshot_cleanup_schedule_name" {
    description = "The name of the schedule to be created and applied to runbook."
}
variable "snapshot_cleanup_schedule_start_time" {
  description = "Time at which the runbook should start. Setting this to 12h would start the runbook 12 hours after deployment."
}


# deploy logic app code

variable "la_resource_group" {
  description = "the resource group to deploy the logic app into"
}

variable "eventhubConn" {
  description = "the name of the connection to the event hub"
}

variable "logicAppName" {
  description = "the name of the logic app"
}

variable "connString" {
  description = "the connection string of the logic app"
}

variable "eventhubname" {
  description = "the name of the event hub - the is the event hub name, NOT the event hub namespace"
}

#### Tagging variables ####
variable "tags" {
  description = "A map of tag values for all Azure resources capable of being tagged. See the 'github.com/Dentsu-Aegis-Network-Global-Technology/clz-tfmodule-base-tags' module for more info."
  type        = "map"
}
