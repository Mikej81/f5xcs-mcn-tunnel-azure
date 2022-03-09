# Environment
// Required Variable
variable "adminUserName" {
  type        = string
  description = "REQUIRED: Admin Username for All systems"
  default     = "xadmin"
}

// Required Variable
variable "location" {
  type        = string
  description = "REQUIRED: Azure Region: usgovvirginia, usgovarizona, etc. For a list of available locations for your subscription use `az account list-locations -o table`"
  default     = "canadacentral"
}
variable "region" {
  type        = string
  description = "Azure Region: US Gov Virginia, US Gov Arizona, etc"
  default     = "Canada Central"
}

variable "sshPublicKey" {
  type        = string
  description = "OPTIONAL: ssh public key for instances"
  default     = ""
}
variable "sshPublicKeyPath" {
  type        = string
  description = "OPTIONAL: ssh public key path for instances"
  default     = "~/.ssh/id_rsa.pub"
}
// Required Variable
variable "api_p12_file" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
  default     = "./api-creds.p12"
}

variable "api_cert" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
  default     = "./api2.cer"
}
variable "api_key" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
  default     = "./api.key"
}
// Required Variable
variable "tenant_name" {
  type        = string
  description = "REQUIRED:  This is your Volterra Tenant Name:  https://<tenant_name>.console.ves.volterra.io/api"
  default     = "mr-customer"
}
// Required Variable
variable "namespace" {
  type        = string
  description = "REQUIRED:  This is your Volterra App Namespace"
  default     = "namespace"
}
// Required Variable
variable "name" {
  type        = string
  description = "REQUIRED:  This is name for your deployment"
  default     = "nebula"
}
// Required Variable
variable "volterra_tf_action" {
  default = "plan"
}
variable "delegated_dns_domain" {
  default = "testdomain.com"
}
// Required Variable
variable "api_url" {
  type        = string
  description = "REQUIRED:  This is your Volterra API url"
  default     = "https://playground.console.ves.volterra.io/api"
}

variable "azure_client_id" { default = "" }
variable "azure_client_secret" { default = "" }
variable "azure_tenant_id" { default = "" }
variable "azure_subscription_id" { default = "" }

variable "gateway_type" { default = "INGRESS_EGRESS_GATEWAY" }
variable "fleet_label" { default = "fleet_label" }

# NETWORK
// Required Variable
variable "cidr" {
  description = "REQUIRED: VNET Network CIDR"
  default     = "10.90.0.0/16"
}

variable "azure_subnets" {
  type        = map(string)
  description = "REQUIRED: Subnet CIDRs"
  default = {
    "external" = "10.90.0.0/24"
    "internal" = "10.90.1.0/24"
  }
}

variable "subnets_nocidr" {
  type        = map(string)
  description = "REQUIRED: Subnet No-CIDRs"
  default = {
    external = "10.90.0.0"
    internal = "10.90.1.0"
  }
}

variable "rh01ip" {
  type        = string
  description = "OPTIONAL: Example Application used by all use-cases to demonstrate functionality of deploymeny, must reside in the application subnet."
  default     = "10.90.1.6"
}

# BIGIP Instance Type, DS5_v2 is a solid baseline for BEST
variable "instanceType" { default = "Standard_DS5_v2" }

# Be careful which instance type selected, jump boxes currently use Premium_LRS managed disks
variable "jumpinstanceType" { default = "Standard_B2s" }

# Demo Application Instance Size
variable "appInstanceType" { default = "Standard_DS3_v2" }

variable "dns_server" {
  type        = string
  description = "REQUIRED: Default is set to Azure DNS."
  default     = "168.63.129.16"
}

## ASM Policy
variable "asm_policy" {
  type        = string
  description = "REQUIRED: ASM Policy.  Examples:  https://github.com/f5devcentral/f5-asm-policy-templates.  Default: OWASP Ready Autotuning"
  default     = "https://raw.githubusercontent.com/f5devcentral/f5-asm-policy-templates/master/owasp_ready_template/owasp-auto-tune-v1.1.xml"
}

variable "ntp_server" { default = "time.nist.gov" }
variable "timezone" { default = "UTC" }
variable "onboard_log" { default = "/var/log/startup-script.log" }

# TAGS
variable "tags" {
  description = "Environment tags for objects"
  type        = map(string)
  default = {
    purpose     = "public"
    environment = "azure"
    owner       = "f5owner"
    group       = "f5group"
    costcenter  = "f5costcenter"
    application = "f5app"
    creator     = "Terraform"
    delete      = "True"
  }
}
