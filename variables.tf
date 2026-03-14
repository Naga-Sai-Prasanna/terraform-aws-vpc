variable "project" {
    type = string
}

variable "environment" {
  type = string
}
variable "vpc_cidr" {
  
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_tags" {
  type = map
  default = {} # Allow users to provide additional tags as a map, which will be merged with the common tags
}

variable "igw_tags" { # This variable is for Internet Gateway tags, similar to vpc_tags
  type = map
  default = {} # Allow users to provide additional tags as a map, which will be merged with the common tags
}

variable "public_subnet_cidrs" {
  type = list
  default = ["10.0.1.0/24", "10.0.2.0/24"] # Default CIDR blocks for public subnets, can be overridden by users
}

variable "public_subnet_tags" {
 
   default = {} # Allow users to provide additional tags for public subnets as a map, which will be merged with the common tags
   type = map
 }

variable "private_subnet_cidrs" {
  type = list
  default = ["10.0.11.0/24", "10.0.12.0/24"] # Default CIDR blocks for private subnets, can be overridden by users
}

variable "private_subnet_tags" {
  type = map
  default = {} # Allow users to provide additional tags for private subnets as a map, which will be merged with the common tags
}           

variable "database_subnet_cidrs" {
  type = list
  default = ["10.0.21.0/24", "10.0.22.0/24"] # Default CIDR blocks for database subnets, can be overridden by users
}

variable "database_subnet_tags" {
 
   default = {} # Allow users to provide additional tags for public subnets as a map, which will be merged with the common tags
   type = map
 }

variable "public_route_table_tags" {
 
   default = {} # Allow users to provide additional tags for public subnets as a map, which will be merged with the common tags
   type = map (string)
 }


 variable "private_route_table_tags" {
 
   default = {} # Allow users to provide additional tags for private route tables as a map, which will be merged with the common tags
   type = map (string)
 }

 
 variable "database_route_table_tags" {
 
   default = {} # Allow users to provide additional tags for database route tables as a map, which will be merged with the common tags
   type = map (string)
 }

 #eip

 variable "eip_tags" {
   default = {} # Allow users to provide additional tags for Elastic IPs as a map, which will be merged with the common tags
   type = map
 }

 variable "nat_gateway_tags" {
   default = {} # Allow users to provide additional tags for NAT Gateway as a map, which will be merged with the common tags
   type = map
   
 }
 variable "is_peering_required" {
   default = false
   type = bool
 }