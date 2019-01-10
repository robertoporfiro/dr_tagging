# Common variables
variable "running_on_mac" {
  default = false
  description = "Switch to ensure Terraform uses the correct executable for powershell based on the operating system running it."
}

variable "rg_name" {
  description = "The name of the resource group to deploy to."
}

variable "location" {
  default = "West Europe"
}

# Automation variables
variable "snapshot_cleanup_script" {
  default = "../../runbookCode/cleanupRunbook.ps1"
  description = "Points to script location on system"
}
variable "snapshot_cleanup_runbook_name" {
  default = "snapshot-cleanup-runbook"
}

variable "aut_acc_name" {
  description = "Name of automation account"
}

variable "snapshot_cleanup_schedule_name" {
  default = "snapshot-cleanup-schedule"
}


data "local_file" "snapshot_cleanup_script" {
  filename = "${var.snapshot_cleanup_script}"
}

# The below variable is used to schedule the first run of the runbook. The runbook will run once an hour
# The first run will be executed based on the variable specified. For example 1h means it will
# first run 1 hour after creation.
variable "snapshot_cleanup_schedule_start_time" {
  default = "1h"
}

variable "tags" {
  description = "A map of tag values for all Azure resources capable of being tagged. See the 'github.com/Dentsu-Aegis-Network-Global-Technology/clz-tfmodule-base-tags' module for more info."
  type        = "map"
}
