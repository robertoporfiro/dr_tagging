variable "managedApiName" {
  default = "eventhubs"
}

variable "rg" {
  default = "newlarg"
}

variable "subscriptionId" {
    default = "7494274c-2e56-4d92-95a5-40071817c7f1"
}

variable "eventhubConn" {
    default = "conns7"
}

variable "logicAppName" {
  default = "seventhdeploy"
}

variable "connString" {
  default = "",
}

variable "eventhubname" {
  default = "initaleh"
}
#### Tagging variables ####
### These are required as ARM doesn't handle arrays being passed from terraform properly
variable "armAutomationTag" {
}
variable "armBpcidTag" {
}
variable "armBusinessTag" {
}
variable "armCoreopsTag" {
}
variable "armMetricsTag" {
}
variable "armSecurityTag" {
}
variable "armTechnicalTag" {
}