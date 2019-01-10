## Description

This is where the powershell scripts that are used in the runbooks are stored.

## Diagram

This diagram shows how the powershell scripts interact with each other and the TF stacks, and give a basic overview of what each script does.</br>
Full diagram here https://www.lucidchart.com/documents/view/ad27d50a-3ff5-4c5e-964d-689c4bf242d0#

## Scripts

1.  modulesRunbook = Updates the powershell modules of an automation account to either the latest version or a required version if specified.
    - Required parameters
        - $ResourceGroupName = Name of the resource group the automation account will reside in.
        - $AutomationAccountName = Name of automation account that will have it's modules updated.

        ```javascript
        # Example
            $ResourceGroupName      = "sm-test-rg"
            $AutomationAccountName  = "sm-test-aa"
        ```


2.  snapshotRunbook = Takes a snapshot of all VMs to be enrolled in the DR solution. Set on a schedule of every 15 minutes.
    - Required parameters
        - $vm1,$vm2,...$vmn = Each VM to be snapshotted. These VM objects require the name, resource group, and subscription id
        - $vmList = List of all the VM's to loop through

        ```javascript
        # Example
            $vm1 = @{
                name = "sm-vm1"
                resourceGroup = "sm-test-rg"
                subscriptionId = "4536n3jj-f343vj5-mfkknnjb-ddsfnnk"
            },
            $vm2 = @{
                name = "sm-vm2"
                resourceGroup = "sm-test-rg"
                subscriptionId = "4536n3jj-f343vj5-mfkknnjb-ddsfnnk"
            },
            $vmList = @($vm1,$vm2)
        ```


3.  cleanupRunbook = Removes old snapshots if there is more than the threshold set. Scheduled every hour.
    - Required parameters
        - $vm1,$vm2,...$vmn = Each VM that's snapshots should be cleaned up. These VM objects require the name, resource group, and subscription id
        - $vmList = List of all the VM's to loop through
        - $numberOfSnapshots = Number of snapshots to keep for each VM. If number of snapshots found for a VM is higher than this the oldest snapshots will be removed

        ```javascript
        # Example
            $vm1 = @{
                name = "sm-vm1"
                resourceGroup = "sm-test-rg"
                subscriptionId = "4536n3jj-f343vj5-mfkknnjb-ddsfnnk"
            },
            $vm2 = @{
                name = "sm-vm2"
                resourceGroup = "sm-test-rg"
                subscriptionId = "4536n3jj-f343vj5-mfkknnjb-ddsfnnk"
            },
            $vmList = @($vm1,$vm2)
            $numberOfSnapshots = 10
        ```

4. re-instatevmRunbook = When a VM is failed over. This script will spin up a new VM with the exact same config as the VM that is failing over.
    - Required parameters
        - $WebhookData = This is passed from the webhook each time the runbook is triggered via an alert thrown by a monitored VM.

5. cleanupInfra = Currently a manual step. This is to be run after a failover occurs and will remove all resources assosciated with the old VM that failed.
    - Required parameters
        - $vm1 = Old VM that has failed. Requires name of VM and the resource group it's in.
        - $vmList = List of VM's to remove. Should normally only be a single VM but it could be required to remove more than one at the same time

        ```javascript
        # Example
            $vm1 = @{
                name = "sm-vm1"
                resourceGroup = "sm-test-rg"
            },
            $vmList = @($vm1)
        ```