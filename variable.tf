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
