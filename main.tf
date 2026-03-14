resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default" # Default is default, can be changed to dedicated if you want to use dedicated instances in the VPC
  enable_dns_hostnames = true # Enable DNS hostnames in the VPC, required for EC2 instances to have public DNS names

  tags = local.vpc_final_tags
  
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # Associate the Internet Gateway with the VPC

  tags = local.igw_final_tags
}

#public subntes
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs) # Create as many public subnets as there are CIDR blocks in the list
    
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index] # Use the corresponding CIDR block for each subnet
    availability_zone = local.az_names[count.index] # Distribute subnets across available AZs
    map_public_ip_on_launch = true # Automatically assign public IPs to instances launched in this subnet
    
    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}" # Name each subnet with the AZ name for better identification
        },
        var.public_subnet_tags # Merge any additional tags provided by the user for public subnets
    )
}

#private subntes
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs) # Create as many private subnets as there are CIDR blocks in the list
    
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index] # Use the corresponding CIDR block for each subnet
    availability_zone = local.az_names[count.index] # Distribute subnets across available AZs
   
    
    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}" # Name each subnet with the AZ name for better identification
        },
        var.private_subnet_tags # Merge any additional tags provided by the user for private subnets
    )
}


#database subntes
resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs) # Create as many public subnets as there are CIDR blocks in the list
    
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_subnet_cidrs[count.index] # Use the corresponding CIDR block for each subnet
    availability_zone = local.az_names[count.index] # Distribute subnets across available AZs
    
    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}" # Name each subnet with the AZ name for better identification
        },
        var.database_subnet_tags # Merge any additional tags provided by the user for database subnets
    )
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    
    tags = merge(
        local.common_tags,
        # roboshop-dev-public
        {
        Name = "${var.project}-${var.environment}-public-rt" # Name the route table for better identification
        },
        var.public_route_table_tags # Merge any additional tags provided by the user for the public route table
    )   
  
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    
    tags = merge(
        local.common_tags,
        # roboshop-dev-private
        {
            Name = "${var.project}-${var.environment}-private" # Name the route table for better identification
        },
        var.private_route_table_tags # Merge any additional tags provided by the user for the private route table
    )
}

resource "aws_route_table" "database" {
    vpc_id = aws_vpc.main.id
    
    tags = merge(
        local.common_tags,
        #   roboshop-dev-database
        {
            Name = "${var.project}-${var.environment}-database" # Name the route table for better identification
        },
        var.database_route_table_tags # Merge any additional tags provided by the user for the database route table
    
    )
}       
       