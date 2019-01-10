# ---------------------------------------------------------------------------
#               VM Details
# ---------------------------------------------------------------------------

variable "vm_name" {
  description = "The name of the VM to enrol in monitoring"
}

variable "vm_resource_group_name" {
  description = "The resource group of the VM to enrol in monitoring"
}

# ---------------------------------------------------------------------------
#               Monitoring Variables
# ---------------------------------------------------------------------------

variable "action_group_name" {
  description = "The action group name as created when Automation_Account_Stack ran"
}

variable "action_group_rg_name" {
  description = "The name of the resource group into which the Action Group has been deployed."
}
variable "alert_name" {
  
}

variable "tags" {
  description = "A map of tag values for all Azure resources capable of being tagged. See the 'github.com/Dentsu-Aegis-Network-Global-Technology/clz-tfmodule-base-tags' module for more info."
  type        = "map"
}

