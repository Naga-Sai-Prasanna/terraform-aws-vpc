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