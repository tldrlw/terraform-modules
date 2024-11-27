# Private Subnets
resource "aws_subnet" "private" {
  count                   = 3
  vpc_id                  = var.VPC_ID
  cidr_block              = "10.0.${count.index + 10}.0/24" # Example CIDR blocks for private subnets
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "private-${var.APP_NAME}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = var.VPC_ID
  # For Gateway VPC Endpoints like DynamoDB, there’s no need to manually add routes to the route table because the aws_vpc_endpoint resource automatically handles this. When you specify the route_table_ids in the aws_vpc_endpoint configuration, AWS automatically adds the necessary routes to the specified route tables, associating the endpoint with the correct prefix list for DynamoDB traffic. This is different from Interface Endpoints (e.g., for API Gateway), which require specific configurations. Manually adding routes with aws_route would cause conflicts or errors, as the endpoint already provides the required connectivity, ensuring seamless and private access to DynamoDB.
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
