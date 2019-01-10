resource "azurerm_monitor_metric_alert" "test" {
  name                = "${var.alertname}"
  resource_group_name = "${data.azurerm_resource_group.vm.name}"
  scopes              = ["${data.azurerm_resource_group.vm.id}/providers/Microsoft.Compute/virtualMachines/${var.vmname}"]
  description         = "This will be triggered if the data transfer on the VM is below 1000 bytes"
  #frequency           = "PT1M"
  #window_size         = "PT1M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network Out"
    aggregation      = "Total"
    operator         = "LessThan"
    threshold        = 1000

  }

  action {
    action_group_id = "${data.azurerm_resource_group.ag.id}/providers/microsoft.insights/actionGroups/${var.actiongroupname}"
  }

  tags = "${var.tags}"
}