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
variable "appSubnet" {}
variable "name" {}
variable "publicip_id" {}

variable "adminPassword" {
  type        = string
  description = "REQUIRED: Admin Password for all systems"
  default     = "pleaseUseVault123!!"
}
variable "location" {
  type        = string
  description = "REQUIRED: Azure Region: usgovvirginia, usgovarizona, etc. For a list of available locations for your subscription use `az account list-locations -o table`"
  default     = "usgovvirginia"
}
variable "region" {
  type        = string
  description = "Azure Region: US Gov Virginia, US Gov Arizona, etc"
  default     = "US Gov Virginia"
}
variable "deploymentType" {
  type        = string
  description = "REQUIRED: This determines the type of deployment; one tier versus three tier: one_tier, three_tier"
  default     = "three_tier"
}
variable "deployDemoApp" {
  type        = string
  description = "OPTIONAL: Deploy Demo Application with Stack. Recommended to show functionality.  Options: deploy, anything else."
  default     = "deploy"
}
variable "sshPublicKey" {
  type        = string
  description = "OPTIONAL: ssh public key for instances"
  default     = ""
}
variable "sshPublicKeyPath" {
  type        = string
  description = "OPTIONAL: ssh public key path for instances"
  default     = "/mykey.pub"
}

# NETWORK
variable "cidr" {
  description = "REQUIRED: VNET Network CIDR"
  default     = "10.90.0.0/16"
}

variable "subnets" {
  type        = map(string)
  description = "REQUIRED: Subnet CIDRs"
  default = {
    "management"  = "10.90.0.0/24"
    "external"    = "10.90.1.0/24"
    "internal"    = "10.90.2.0/24"
    "vdms"        = "10.90.3.0/24"
    "inspect_ext" = "10.90.4.0/24"
    "inspect_int" = "10.90.5.0/24"
    "waf_ext"     = "10.90.6.0/24"
    "waf_int"     = "10.90.7.0/24"
    "application" = "10.90.10.0/24"
  }
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
variable "app01ip" {
  type        = string
  description = "OPTIONAL: Example Application used by all use-cases to demonstrate functionality of deploymeny, must reside in the application subnet."
  default     = "10.90.10.101"
}

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
