resource "azurerm_template_deployment" "logicAppDeploy" {
  name                = "${var.logicAppName}-deployment"
  resource_group_name = "${data.azurerm_resource_group.base.name}"

  template_body = <<DEPLOY
    {
        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "connections_eventhubs_name": {
                "defaultValue": "conns5",
                "type": "String"
            },
            "managedapiname": {
                "defaultValue": "eventhubs",
                "type": "String"
            },
            "subscriptionid": {
                "defaultValue": "7494274c-2e56-4d92-95a5-40071817c7f1",
                "type": "String"
            },
            "laName": {
                "defaultValue": "fifthdeploy",
                "type": "String"
            },
            "eventhubname": {
                "defaultValue": "initaleh",
                "type": "String"
            },
            "loc": {
                "defaultValue": "westeurope",
                "type": "String"
            },
            "connstring":{
                "type": "String"
            },
            "automationTag": {
                "type": "String"
            },
            "bpcidTag": {
                "type": "String"
            },
            "businessTag": {
                "type": "String"
            },
            "coreopsTag": {
                "type": "String"
            },
            "metricsTag": {
                "type": "String"
            },
            "securityTag": {
                "type": "String"
            },
            "technicalTag": {
                "type": "String"
            }
        },
        "variables": {},
        "resources": [
            {
                "type": "Microsoft.Logic/workflows",
                "name": "[parameters('laName')]",
                "apiVersion": "2017-07-01",
                "location": "[parameters('loc')]",
                "tags": {
                    "automation":"[parameters('automationTag')]",
                    "bpcid":"[parameters('bpcidTag')]",
                    "business":"[parameters('businessTag')]",
                    "coreops":"[parameters('coreopsTag')]",
                    "metrics":"[parameters('metricsTag')]",
                    "security":"[parameters('securityTag')]",
                    "technical":"[parameters('technicalTag')]",
                },
                "scale": null,
                "properties": {
                    "state": "Enabled",
                    "definition": {
                        "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
                        "contentVersion": "1.0.0.0",
                        "parameters": {
                            "$connections": {
                                "defaultValue": {},
                                "type": "Object"
                            }
                        },
                        "triggers": {
                            "manual": {
                                "type": "Request",
                                "kind": "Http",
                                "inputs": {
                                    "method": "POST",
                                    "schema": {}
                                }
                            }
                        },
                        "actions": {
                            "Send_event": {
                                "runAfter": {},
                                "type": "ApiConnection",
                                "inputs": {
                                    "body": {
                                        "ContentData": "@{base64(triggerBody())}"
                                    },
                                    "host": {
                                        "connection": {
                                            "name": "@parameters('$connections')['eventhubs']['connectionId']"
                                        }
                                    },
                                    "method": "post",
                                    "path": "/@{encodeURIComponent(parameters('$connections')['eventhubs']['otherpath'])}/events"
                                }
                            }
                        },
                        "outputs": {}
                    },
                    "parameters": {
                        "$connections": {
                            "value": {
                                "eventhubs": {
                                    "connectionId": "[resourceId('Microsoft.Web/connections', parameters('connections_eventhubs_name'))]",
                                    "connectionName": "eventhubs",
                                    "id": "[concat('/subscriptions/', parameters('subscriptionid'), '/providers/Microsoft.Web/locations/', parameters('loc'), '/managedApis/', parameters('managedapiname'))]",
                                    "otherpath": "[parameters('eventhubname')]",
                                    "otherpath1": "/@{encodeURIComponent('eventhub')}/events"
                                }
                            }
                        }
                    }
                },
                "dependsOn": [
                    "[resourceId('Microsoft.Web/connections', parameters('connections_eventhubs_name'))]"
                ]
            },
            {
                "type": "Microsoft.Web/connections",
                "name": "[parameters('connections_eventhubs_name')]",
                "apiVersion": "2016-06-01",
                "location": "[parameters('loc')]",
                "scale": null,
                "properties": {
                    "displayName": "[parameters('connections_eventhubs_name')]",
                    "parameterValues": {
                        "connectionString":"[parameters('connstring')]"
                    },
                    "api": {
                        "id": "[concat('/subscriptions/', parameters('subscriptionid'), '/providers/Microsoft.Web/locations/', parameters('loc'), '/managedApis/', parameters('managedapiname'))]"
                    }
                },
                "dependsOn": []
            }
        ]
    }
DEPLOY

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters {
    "connections_eventhubs_name"=   "${var.eventhubConn}"
    "managedapiname"            =   "${var.managedApiName}"
    "subscriptionid"            =   "${var.subscriptionId}"
    "laName"                    =   "${var.logicAppName}"
    "loc"                       =   "${data.azurerm_resource_group.base.location}"
    "connstring"                =   "${var.connString}"
    "eventhubname"              =   "${var.eventhubname}"
    "automationTag"             = "${var.armAutomationTag}"
    "bpcidTag"                  = "${var.armBpcidTag}"
    "businessTag"               = "${var.armBusinessTag}"
    "coreopsTag"                = "${var.armCoreopsTag}"
    "metricsTag"                = "${var.armMetricsTag}"
    "securityTag"               = "${var.armSecurityTag}"
    "technicalTag"              = "${var.armTechnicalTag}"
  }

  deployment_mode = "Incremental"
}