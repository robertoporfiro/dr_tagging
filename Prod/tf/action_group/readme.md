## Description

This TF uses the runtime local machines powershell to create the action group and webhook for triggering the failover.</br>
Full diagram can be found here https://www.lucidchart.com/documents/view/ca67dd31-9bf0-407d-8e4f-8ba1f3cf21f4/0

## Resources created

- null resource (This runs a local-execution of powershell to create the webhook and action group)

## Variables 

The variables for this module are passed through the Automation_Account_Stack. They are</br>
- resource_group
- subscription_id
- automation_account_name
- runbook_name
- webhook_name
- action_group_name
- running_on_mac
- la_resource_group
- la_name

Descriptions for these variables can be found in the inputs.tf file.</br>

## Example Variables
```javascript
resource_group = "test-rg"
subscription_id = "7494274c-2e56-4d92-95a5-40071817c7f1"
automation_account_name = "test-automation-account"
runbook_name = "test-runbook"
webhook_name = "test-webhook"
action_group_name = "test-action-group"
running_on_mac = true
la_resource_group = "test-la-rg"
la_name = "test-la"
```