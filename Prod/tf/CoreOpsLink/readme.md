## Description

This module is used to spin up the logic app to enable fail over events to be tracked by coreops. 

There is currently an event hub that CoreOps use to integrate alerts from azure into their alerting platform. 
Because of this we have elected to make use of the same event hub to include alerts from the auto failover solution.

This makes use of a logic app to read data from a webhook and pass it to the event hub. 
In order to do this, we have to create a logic app and a connection to the event hub. 
We have also had to modify the original terraform stack to include the second item in the action group. 

The below diagram describes the connection flow between health monitoring -> action group -> runbook and logic app 

![alt text](https://www.lucidchart.com/publicSegments/view/73c1a52b-b200-44c3-98ea-9c98b7775a4b/image.png "Automation_Acccount_Stack calls")

See https://www.lucidchart.com/documents/view/15497d40-fcdd-444f-b73c-b565289a0ec0/0 for full diagram.

## Variable Description

managedApiName: This is the api to connect to the event hub should always be set to eventhubs

rg: this is the resource group to deploy the logic app to

subscriptionId: the subscription ID

eventhubConn: the name of the connection resource (can more or less be anything)

logicAppName: the name of the logic app

connString: the connection string for the event hub, either a newly created one of default

    https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-get-connection-string

eventhubname: the name of the event hub (NOT the event hub name space!)

## Example Variables
```javascript

managedApiName = "eventhubs"
rg = "newlarg"
subscriptionId = "234kmd33-33gs-44dd-2df5-23jfjsn56424"
eventhubConn = "conns7"
logicAppName = "seventhdeploy"
connString = "Endpoint=sb://<eventhub>.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=12345678765432345678987654="
eventhubname = "initaleh"

```
