
variable "resource_group" {
  default = "bf-dr-rg"
  description = "Resource group the automation account and everything assosciated to it will be created in"
}

variable "subscription_id" {
  description = "subscription id of the subscription the resources will be in"
}


variable "automation_account_name" {
  default = "bf-dr-aac"
  description = "name of the automation account that the runbooks will be run from. This account will already have been created"
}

variable "runbook_name" {
  description = "The name of the runbook to create a webhook for. This run book MUST BE PUBLISHED"
  default = "failover_test_Matt"
}

variable "webhook_name" {
  default = "dr_test"
  description = "Name for the webhook being created"
}

variable "action_group_name" {
  description = "Name for the action group being created. Must be more than 6 characters"
  default = "dr_trigger"
}

variable "running_on_mac" {
  default = false
  description = "Switch to ensure Terraform uses the correct executable for powershell based on the operating system running it"
}

variable "la_resource_group" {
  description = "Logic app resource group name"
}

variable "la_name" {
  description = "Name of the logic app"
}

#### Tagging variables ####
variable "tags" {
  description = "A map of tag values for all Azure resources capable of being tagged. See the 'github.com/Dentsu-Aegis-Network-Global-Technology/clz-tfmodule-base-tags' module for more info."
  type        = "map"
}


