resource "aws_vpc_peering_connection" "default" {
  count = var.is_peering_required ? 1 : 0 # Create the peering connection only if peering is required
  #peer_owner_id = var.peer_owner_id # The AWS account ID of the owner of the peer VPC, provided by the user
  
   #Acceptor
   peer_vpc_id = data.aws_vpc.default.id        # The ID of the VPC to
   
   #requestor
   vpc_id = aws_vpc.main.id

   auto_accept =  true # Automatically accept the peering connection request, eliminating the need for manual acceptance

   accepter {
     allow_remote_vpc_dns_resolution = true

   } 
   requester {
     allow_remote_vpc_dns_resolution = true
   }

   tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-default   " # Name the peering connection for better identification
    }
   )

}

#peering connection routes

resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1 : 0 # Create routes only if peering is required and there are CIDR blocks to route

  route_table_id         = aws_route_table.public.id # The ID of the route table to which the route will be added
  destination_cidr_block = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # Route traffic through the peering connection
}


resource "aws_route" "private_peering" {
  count = var.is_peering_required ? 1 : 0 # Create routes only if peering is required and there are CIDR blocks to route

  route_table_id         = aws_route_table.private.id # The ID of the route table to which the route will be added
  destination_cidr_block = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # Route traffic through the peering connection
}

resource "aws_route" "database_peering" {
  count = var.is_peering_required ? 1 : 0 # Create routes only if peering is required and there are CIDR blocks to route

  route_table_id         = aws_route_table.database.id # The ID of the route table to which the route will be added
  destination_cidr_block = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # Route traffic through the peering connection
}


resource "aws_route" "default_peering" {
  count = var.is_peering_required ? 1 : 0 # Create routes only if peering is required and there are CIDR blocks to route

  route_table_id         = data.aws_route_table.default.id # The ID of the route table to which the route will be added
  destination_cidr_block = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # Route traffic through the peering connection
}
