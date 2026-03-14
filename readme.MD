# Terraform AWS VPC

This module creates following resources
1. VPC
2. IGW with VPC association
3. Subnets -> Public private database
4. route tables -> Public private database
5. Association and Routes
6. EIP
7. NAT gateway
8. VPC Perring with default VPC on condition
9. Route table entries through peering


## Inputs


project - (Required) string type. User should pass the project name
environment - (Required) string type. User should pass the environment, values should be one of dev,uat,qa and prod

## Outputs

