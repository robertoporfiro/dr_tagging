provider "azurerm" {}
module "enrol_monitoring" {
    source          = "../../enrol_monitoring"
    actiongroupname = "${var.action_group_name}"
    alertname = "${var.alert_name}"
    vmname = "${var.vm_name}"
    vmrg = "${var.vm_resource_group_name}"
    agrg = "${var.action_group_rg_name}"
}
