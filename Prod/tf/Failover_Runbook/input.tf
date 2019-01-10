# Common variables

variable "rg_name" {
  description = "Resource group the automation account where the runbook will be published is in"
}

variable "location" {
  default = "West Europe"
}

variable "subscription" {
  description = "Subscription id"
}

# Automation variables
variable "failover_script" {
  description = "Points to location of script on system"
  default = "../../runbookCode/re-instatevmRunbook.ps1"
}

variable "aut_acc_name" {
  description = "Automation account name"
}

variable "failover_runbook_name" {
  default = "failover_runbook" # This should be left as 'failover_runbook' as there are dependencies on this name
}

data "local_file" "failover_script" {
  filename = "${var.failover_script}"
}

variable "tags" {
  description = "A map of tag values for all Azure resources capable of being tagged. See the 'github.com/Dentsu-Aegis-Network-Global-Technology/clz-tfmodule-base-tags' module for more info."
  type        = "map"
}
