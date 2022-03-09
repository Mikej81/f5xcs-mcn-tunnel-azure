# Azure Environment
variable "projectPrefix" {
  type        = string
  description = "REQUIRED: Prefix to prepend to all objects created, minus Windows Jumpbox"
  default     = "ccbad9e7"
}
variable "adminUserName" {
  type        = string
  description = "REQUIRED: Admin Username for All systems"
  default     = "xadmin"
}
variable "resource_group" {}
variable "security_group" {}
variable "rhSubnet" {}
variable "name" {}
variable "publicip_id" {}

variable "adminPassword" {
}
variable "location" {
}
variable "region" {
}
variable "sshPublicKey" {
}
variable "sshPublicKeyPath" {
}


# Be careful which instance type selected, jump boxes currently use Premium_LRS managed disks
variable "jumpinstanceType" { default = "Standard_B2s" }

# Demo Application Instance Size
variable "appInstanceType" { default = "Standard_DS3_v2" }

variable "dns_server" {}
variable "publicip" {}
variable "instanceType" {}

variable "ntp_server" { default = "time.nist.gov" }
variable "timezone" { default = "UTC" }
variable "onboard_log" { default = "/var/log/startup-script.log" }
variable "rh01ip" {}

# TAGS
variable "tags" {
  description = "Environment tags for objects"
  type        = map(string)
  default = {
    "purpose"     = "public"
    "environment" = "f5env"
    "owner"       = "f5owner"
    "group"       = "f5group"
    "costcenter"  = "f5costcenter"
    "application" = "f5app"
  }
}
