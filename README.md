# F5 XCS MCN Tunnel for Azure (IP Obfuscation / Global Egress)

Automated deployment of Multi Cloud Networking Azure CE, with populated routes and connectors.

## Introduction

This template is designed around the concept of using a Customer Edge (CE) in a Cloud Service Provider (Azure in this use-case) as an egress endpoint.

## Deployment

### Local

To get everything set up, first deploy a Customer Edge Site in your local datacenter.  Guidance on that can be found here:  [https://docs.cloud.f5.com/docs/how-to/site-management](https://docs.cloud.f5.com/docs/how-to/site-management)

Once you have your local customer edge site deployed, then create a fleet.  Guidance on that can be found here:  [https://docs.cloud.f5.com/docs/how-to/fleets-vsites/create-a-fleet](https://docs.cloud.f5.com/docs/how-to/fleets-vsites/create-a-fleet)

Virtual Networks [https://docs.cloud.f5.com/docs/how-to/networking/virtual-networks](https://docs.cloud.f5.com/docs/how-to/networking/virtual-networks)
Network Connectors [https://docs.cloud.f5.com/docs/how-to/networking/network-connectors](https://docs.cloud.f5.com/docs/how-to/networking/network-connectors)

### Remote

To get our remote site spun up, its actually pretty simple, since its covered in the provided terraform.

First we need to prep, an example script is provided that shows how you will set your XCS API Path and Password, log in to azure and map subscription and tenant, create an SPN and map the AppID and Secret so we can create a Cloud Credential:

```bash
. ./prep.sh
```

Once everything is mapped and updated: ensure that you have either updated the variables.tf, created an override or tfvars with your desired settings and then:

```bash
$terraform init
(optional)$ terraform plan
$terraform apply --auto-approve
```

### Local Part II

Once terraform completes, you will have a one config left to make.  The terraform will create two network connectors, one will automatically be tied to the remote cloud site.  The other will show in the terraform output.  Map this one to your global network connectors in your local fleet.

Win!
