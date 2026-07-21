resource "aws_vpc_peering_connection" "default" {
    count = var.is_peering_required ? 1 : 0

# acceptor
    peer_vpc_id = data.aws_vpc.default.id

# requestor
    vpc_id =  aws_vpc.main.id  

 # if they are in same account
    auto_accept = true

    accepter {
       allow_remote_vpc_dns_resolution = true
    }

    requester {
        allow_remote_vpc_dns_resolution = true
    }

    tags =  merge(
        local.common_tags,
        {
          Name = "${var.project}-${var.environment}=default"
        }
    )

}

# adding routes in each vpc

resource "aws_route" "public_peering" {
    count = var.is_peering_required ? 1 : 0
    route_table_id = aws_route_table.public.id
    destination_cidr_block = data.aws_vpc.default.cidr_block
    # here we have to use count.index beacuse we used count and terraform treat it as a list
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

resource "aws_route" "private_peering" {
    count = var.is_peering_required ? 1 : 0
    route_table_id = aws_route_table.private.id
    destination_cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

resource "aws_route" "database_peering" {
    count = var.is_peering_required ? 1 : 0
    route_table_id = aws_route_table.database.id
    destination_cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}


resource "aws_route" "default_peering" {
    count = var.is_peering_required ? 1 : 0
    route_table_id = data.aws_route_table.default.id
    destination_cidr_block = var.vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id

}