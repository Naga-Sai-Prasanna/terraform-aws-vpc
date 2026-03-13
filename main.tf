resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default" # Default is default, can be changed to dedicated if you want to use dedicated instances in the VPC
  enable_dns_hostnames = true # Enable DNS hostnames in the VPC, required for EC2 instances to have public DNS names

  tags = vpc_final_tags
  
}