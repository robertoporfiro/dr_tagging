provider "azurerm" {subscription_id="23666e70-4091-4ab9-929c-9ef08446f52e"}

module "tags" {
  source = "git::https://stuart-melrose:d3b9c83838baa1474994c192053a1cf7f33210c1@github.com/Dentsu-Aegis-Network-Global-Technology/clz-tfmodule-base-tags?ref=1.0.0"
  tags   = "${var.tags}"
}

locals {
    arm_automation_tag = "${module.tags.tags["automation"]}"
    arm_bpcid_tag = "${module.tags.tags["bpcid"]}"
    arm_business_tag = "${module.tags.tags["business"]}"
    arm_coreops_tag = "${module.tags.tags["coreops"]}"
    arm_metrics_tag = "${module.tags.tags["metrics"]}"
    arm_security_tag = "${module.tags.tags["security"]}"
    arm_technical_tag = "${module.tags.tags["technical"]}"
}

module "LogicApp" {
  source = "../../CoreOpsLink"

    managedApiName = "eventhubs"
    rg = "${var.la_resource_group}"
    subscriptionId = "${var.subscription}"
    eventhubConn = "${var.eventhubConn}"
    logicAppName = "${var.logicAppName}"
    connString = "${var.connString}"
    eventhubname = "${var.eventhubname}"
#Tags for ARM. These are required as ARM doesn't handle the tags in array form. Need to be passed as parameters individually as workaround
    armAutomationTag = "${local.arm_automation_tag}"
    armBpcidTag = "${local.arm_bpcid_tag}"
    armBusinessTag = "${local.arm_business_tag}"
    armCoreopsTag = "${local.arm_coreops_tag}"
    armMetricsTag = "${local.arm_metrics_tag}"
    armSecurityTag = "${local.arm_security_tag}"
    armTechnicalTag = "${local.arm_technical_tag}"
}

module "Automation_Account" {
  source = "../../Automation_Account"
  
# Common variables
    
    running_on_mac = "${var.running_on_mac}"
    rg_name = "${var.resource_group_name}"
    location = "${var.location}"
    subscription = "${var.subscription}"
    certificate_thumbprint = "${var.certificate_thumbprint}"
    application_id = "${var.application_id}"
    tenant_id = "${var.tenant_id}"

# Automation variables
    aut_acc_name = "${var.automation_account_name}"
    pricing_tier = "${var.automation_account_pricing_tier}"
    connection_name = "${var.connection_name}"
    connection_type_name = "${var.connection_type_name}"
    connection_certificate_name = "${var.connection_certificate_name}"
    cert_password = "${var.cert_password}"
    keyvault_name = "${var.keyvault_name}"
    automation_cert_name = "${var.automation_cert_name}"

# Modules Runbook Variables

    modules_script = "${var.modules_script}"
    modules_runbook_name = "${var.modules_runbook_name}"

# Snapshot Module Variables

    schedule_name = "${var.schedule_name}"
    snapshot_script = "${var.snapshot_script}"
    snapshot_runbook_name = "${var.snapshot_runbook_name}"

# Failover Module Variables

    failover_script = "${var.failover_script}"
    failover_runbook_name = "${var.failover_runbook_name}" # This should be left as 'failover_runbook' as there are dependencies on this name

# Snapshot Cleanup Module

    snapshot_cleanup_script = "${var.snapshot_cleanup_script}"
    snapshot_cleanup_runbook_name = "${var.snapshot_cleanup_runbook_name}"
    snapshot_cleanup_schedule_name = "${var.snapshot_cleanup_schedule_name}"
    snapshot_cleanup_schedule_start_time = "${var.snapshot_cleanup_schedule_start_time}"

#native TF tags
    tags = "${module.tags.tags}"
#Tags for ARM. These are required as ARM doesn't handle the tags in array form. Need to be passed as parameters individually as workaround
    armAutomationTag = "${local.arm_automation_tag}"
    armBpcidTag = "${local.arm_bpcid_tag}"
    armBusinessTag = "${local.arm_business_tag}"
    armCoreopsTag = "${local.arm_coreops_tag}"
    armMetricsTag = "${local.arm_metrics_tag}"
    armSecurityTag = "${local.arm_security_tag}"
    armTechnicalTag = "${local.arm_technical_tag}"
}

module "Action_Group" {
    source = "../../Action_Group"
    running_on_mac = "${var.running_on_mac}"
    resource_group = "${var.resource_group_name}"
    subscription_id = "${var.subscription}"
    automation_account_name = "${module.Automation_Account.automation_account_name}"
    runbook_name = "${var.failover_runbook_name}"
    webhook_name = "${var.webhook_name}"
    action_group_name = "${var.action_group_name}"
    la_resource_group = "${var.la_resource_group}"
    la_name = "${var.logicAppName}"
    tags = "${module.tags.tags}"
}


