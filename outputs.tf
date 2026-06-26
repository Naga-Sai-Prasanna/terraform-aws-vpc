output "azs_info" {
  value = data.aws_availability_zones.available.names
}

#to retreive the output and use it in aws_sg

output "vpc_id" {
  value = aws_vpc.main.id
}

# to retrive the subnets and store in vpc parameters.tf

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  value = aws_subnet.database[*].id
}