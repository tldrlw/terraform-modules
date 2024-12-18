# Create a Single Private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = var.VPC_ID
  cidr_block              = var.PRIVATE_SUBNET_CIDR
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "private-vpn-client-${data.aws_availability_zones.available.names[0]}"
  }
}

# Create a Private Route Table for the Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = var.VPC_ID
  tags = {
    Name = "Private Subnet Route Table"
  }
}
# Your private subnet’s route table determines where traffic from instances in the subnet (including VPN clients) is sent.

# Associate the Subnet with the Private Route Table
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_route_table.id
}
