# Common variables
variable "running_on_mac" {
  default = false
  description = "Switch to ensure Terraform uses the correct executable for powershell based on the operating system running it."
}

variable "rg_name" {
  description = "The name of the resource group to deploy to."
}

variable "subscription_id" {
  description = "The subscription to deploy to."
}

variable "location" {
  default = "West Europe"
}

# Automation variables
variable "modules_script" {
  description = "Points to script location on system"
  default = "../../runbookCode/modulesRunbook.ps1"
}
variable "modules_runbook_name" {}

variable "aut_acc_name" {
  description = "Name of automation account"
}

data "local_file" "modules_script" {
  filename = "${var.modules_script}"
}

variable "tags" {
  description = "A map of tag values for all Azure resources capable of being tagged. See the 'github.com/Dentsu-Aegis-Network-Global-Technology/clz-tfmodule-base-tags' module for more info."
  type        = "map"
}
