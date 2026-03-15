locals {
    common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = "true"
    }

    vpc_final_tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    },
    var.vpc_tags
  )

  igw_final_tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    },
    var.igw_tags
  )

  
  az_names = slice(data.aws_availability_zones.available.names, 0,2) # Get as many AZ names as there are public subnet CIDR blocks
  public_subnet_names = merge(
    local.common_tags,
    #roboshop-dev-public-us-east-1a
   

    var.public_subnet_tags 
  )
}

    
