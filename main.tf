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
       

 # aws route
 resource "aws_route" "public" {
    route_table_id = aws_route_table.public.id # Associate the route with the public route table
    destination_cidr_block = "0.0.0.0/0" # Route all outbound traffic to the Internet Gateway
    gateway_id = aws_internet_gateway.main.id # Specify the Internet Gateway as the target for the route
 }

#elastic ip for nat gateway
resource "aws_eip" "nat" {
    domain = "vpc" # Allocate the Elastic IP for use with a NAT Gateway in a VPC
    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-nat" # Name the Elastic IP for better identification
        },
        var.eip_tags # Merge any additional tags provided by the user for the NAT Gateway Elastic IP        
    )
}   
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id # Use the allocated Elastic IP for the NAT Gateway
  subnet_id = aws_subnet.public[0].id # Place the NAT Gateway in the first public subnet

   tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}" # Name the NAT Gateway for better identification
    },
    var.nat_gateway_tags # Merge any additional tags provided by the user for the NAT Gateway                       
   )

   #to ensure proper ordering,it is recommend to add an explict dependency
   # on tye interent gateway formvpc
   depends_on = [ aws_internet_gateway.main] # here we are ensuring that the NAT Gateway is created only after the Internet Gateway is created, because the NAT Gateway needs to be associated with a public subnet that has a route to the Internet Gateway. By adding this dependency, we can avoid potential issues with resource creation order and ensure that the infrastructure is set up correctly.
}

resource "aws_route" "private" {
    route_table_id = aws_route_table.private.id # Associate the route with the private route table
    destination_cidr_block = "0.0.0.0/0" # Route all outbound traffic to the NAT Gateway
    nat_gateway_id = aws_nat_gateway.main.id # Specify the NAT Gateway as the target for the route
}

resource "aws_route" "database" {
    route_table_id = aws_route_table.database.id # Associate the route with the database route table
    destination_cidr_block = "0.0.0.0/0" # Route all outbound traffic to the NAT Gateway
    nat_gateway_id = aws_nat_gateway.main.id # Specify the NAT Gateway as the target for the route
}
