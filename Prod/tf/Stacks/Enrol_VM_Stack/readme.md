## Description

This stack creates a metric alert and enrolls the VM into it.
Full diagram here https://www.lucidchart.com/documents/view/aa0d5fc8-7931-4e87-ae16-5f168f5a7b3b/0

## Variable Description

See input.tf file for variable description.

## Example Variables
```javascript
# VM Details
    vm_name = "bf-suse-03"
    vm_resource_group_name = "bf-dr-rg"

# Monitoring Variables
    alert_name      = "afalert"
    action_group_name = "AG_full-test"
    action_group_rg_name = "bf-dr-rg"
```
