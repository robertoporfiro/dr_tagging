### variables
variable "actiongroupname" {
  default = "runbooktrigger"
  description = "Name of action group being created by the action_group module"
}

variable "vmname" {
  default = "failovervm2-dr01"
  description = "Name of VM to enrol in monitoring"
}

variable "alertname" {
  default = "afalert"
}

variable "vmrg" {
  default = "VMSS-BACKUP-TEST-RG"
  description = "Resource group VM is in"
}

variable "agrg" {
  default = "VMSS-BACKUP-TEST-RG"
  description = "Resource group action group is in"
}


### data
data "azurerm_resource_group" "vm" {
  name     = "${var.vmrg}"
}

data "azurerm_resource_group" "ag" {
  name     = "${var.agrg}"
}

variable "tags" {
  description = "A map of tag values for all Azure resources capable of being tagged. See the 'github.com/Dentsu-Aegis-Network-Global-Technology/clz-tfmodule-base-tags' module for more info."
  type        = "map"
}

