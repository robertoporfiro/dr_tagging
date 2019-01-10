# Common variables
variable "rg_name" {}

variable "location" {
  default = "West Europe"
}

variable "subscription" {}

# Automation variables
variable "snapshot_script" {
  default = "../../runbookCode/snapshotRunbook.ps1"
  description = "Points to script location on system"
}

variable "aut_acc_name" {
  description = "Name of automation account"
}

variable "schedule_name" {
  default = "test-schedule"
}

variable "snapshot_runbook_name" {
  default = "test-runbook"
}

variable "snapshot_schedule_interval_minutes" {
  default = "15"
  description = "How often in minutes to run the snapshot runbook"
}

data "local_file" "snapshot_script" {
  filename = "${var.snapshot_script}"
}

variable "tags" {
  description = "A map of tag values for all Azure resources capable of being tagged. See the 'github.com/Dentsu-Aegis-Network-Global-Technology/clz-tfmodule-base-tags' module for more info."
  type        = "map"
}

