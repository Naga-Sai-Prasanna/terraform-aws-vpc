# Terraform AWS VPC

**Role: Module Developer**

A reusable Terraform module for provisioning a complete AWS VPC setup, including public, private, and database subnets, routing, NAT, and optional VPC peering with the default VPC. This repo defines the module only — it is not applied directly, but called from a module-user repo.

## What This Module Creates

- VPC
- Internet Gateway (IGW), associated with the VPC
- Subnets — Public, Private, and Database tiers
- Route tables — Public, Private, and Database tiers
- Route table associations and routes
- Elastic IP (EIP)
- NAT Gateway
- VPC Peering with the default VPC (conditional)
- Route table entries for the peering connection

## File Structure

| File | Purpose |
|------|---------|
| `main.tf` | Core resources — VPC, IGW, subnets, NAT gateway, EIP |
| `locals.tf` | Local values used to compute names, CIDR blocks, and tags |
| `data.tf` | Data sources (e.g. availability zones, default VPC lookup) |
| `peering.tf` | Conditional VPC peering with the default VPC and related routes |
| `variables.tf` | Input variable definitions |
| `outputs.tf` | Output value definitions |

## Usage

```hcl
module "vpc" {
  source = "github.com/Naga-Sai-Prasanna/terraform-aws-vpc"

  project     = "roboshop"
  environment = "dev"
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `project` | The project name, used for naming and tagging resources | `string` | Yes |
| `environment` | The environment name. Must be one of: `dev`, `uat`, `qa`, `prod` | `string` | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | The ID of the created VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `database_subnet_ids` | List of database subnet IDs |
| `nat_gateway_id` | The ID of the NAT Gateway |

> Check `outputs.tf` for exact output names — update this table to match if they differ.

## How This Fits Into the Bigger Picture

This module is one of three reusable building blocks used by the RoboShop infrastructure. It does not depend on the other modules, but is consumed by them:

```
terraform-aws-vpc  ──┐
                      ├──>  terraform-aws-sg  (needs this module's vpc_id)
                      │
                      └──>  roboshop-infra-dev  (module user — calls this module directly, per environment)
```

- **[`terraform-aws-sg`](https://github.com/Naga-Sai-Prasanna/terraform-aws-sg)** — a sibling module-developer repo that creates security groups; it requires the `vpc_id` output from this module.
- **[`terraform-roboshop-component`](https://github.com/Naga-Sai-Prasanna/terraform-roboshop-component)** — a module-developer repo for individual RoboShop app components; it runs inside the subnets created by this module.
- **[`roboshop-infra-dev`](https://github.com/Naga-Sai-Prasanna/roboshop-infra-dev)** — the module-user repo. It calls this module (along with `terraform-aws-sg` and `terraform-roboshop-component`) to provision the full dev environment, numbered as its `00-vpc` step.

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.x |
| AWS Provider | >= 5.x |
