#1.vpc

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    enable_dns_hostnames = true

    tags = local.vpc_final_tags
}

#2. internet gateway

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id #vpc association
    
    tags = local.igw_final_tags
}

#3.subnets-public

resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = true

    tags = merge(
        local.common_tags,
        # robohop-dev-public-us-east-1a and 1b
        {
            Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
        },
        var.public_subnet_tags

    )
}    

#private

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]


    tags = merge(
        local.common_tags,
        # robohop-dev-public-us-east-1a and 1b
        {
            Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"
        },
        var.private_subnet_tags

    )
}    


#database

resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]


    tags = merge(
        local.common_tags,
        # robohop-dev-public-us-east-1a and 1b
        {
            Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"
        },
        var.database_subnet_tags

    )
} 


# route table-public

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-public"
        },
        var.public_route_table_tags
    )
}

# route table-private

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-private"
        },
        var.private_route_table_tags
    )
}


# route table-database

resource "aws_route_table" "database" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-database"
        },
        var.database_route_table_tags
    )

}

# add route 0.0.0.0.for public subnet
resource "aws_route" "public" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

# we need to create nat for private.so first we have to create elastic ip.

#eip

resource "aws_eip" "elastic" {
    domain = "vpc"

    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-nat"
        },
        var.eip_tags
    )
}


#nat gateway
# it is sit on the public subnet

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.elastic.id
    subnet_id = aws_subnet.public[0].id

    tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        },
        var.nat_gateway_tags
    )

    # to emsure proper ordering, it is recommended to add an explicit dependency
    # on the igw for the vpc

    depends_on = [ aws_internet_gateway.igw ]
}

# # route for private subnet --> open nat access

resource "aws_route" "private" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
}

# route for database subnet --> open nat access 

resource "aws_route" "database" {
    route_table_id = aws_route_table.database.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
}


# route table association

resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidrs)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id

}



resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidrs)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id

}


resource "aws_route_table_association" "database" {
    count = length(var.database_subnet_cidrs)
    subnet_id = aws_subnet.database[count.index].id
    route_table_id = aws_route_table.database.id

}


# it is for rds (datasubnet)

resource "aws_db_subnet_group" "roboshop" {
  name       = "${var.project}-${var.environment}"
  subnet_ids = [aws_subnet.database[0].id,aws_subnet.database[1].id]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}" # Name the NAT Gateway for better identification
    }
  )
  }
