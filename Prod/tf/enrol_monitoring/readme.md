## Description

This TF creates a metric alert with a VM in the scope. It creates the alert on specific metrics defined in the terraform code. It then links the alert to an action group.</br>
Full diagram here https://www.lucidchart.com/documents/view/aa0d5fc8-7931-4e87-ae16-5f168f5a7b3b/0

## Resources created

- Metric alert

## Variables 

The variables for this module are passed though the enrol_VM_Stack. These are</br>
- actiongroupname
- vmname
- alertname
- vmrg
- agrg

Descriptions for these variables can be found in the inputs.tf file.</br>
## Example Variables
```javascript
actiongroupname = "test-action-group"
vmname = "test-vm1"
alertname = "test-alert"
vmrg = "test-vm-rg"
agrg = "test-rg"
```