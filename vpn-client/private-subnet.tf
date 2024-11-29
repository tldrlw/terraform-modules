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
# For the VPN clients to reach resources like your API Gateway, the route table of the subnet must have proper routes to direct traffic from the VPN CIDR to the correct target (e.g., to the API Gateway in the same VPC or a NAT gateway if it’s external).

resource "aws_route" "vpn_to_vpc" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = var.VPC_CIDR # e.g., "10.0.0.0/16"
  # ^ ensures that traffic from the VPN clients (which will be in the CLIENT_CIDR) can reach resources in the VPC (e.g., the API Gateway in the 10.0.0.0/16 CIDR block).
  gateway_id = "local" # This uses the VPC's local gateway, which is automatically available in every VPC
}

# Associate the Subnet with the Private Route Table
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_route_table.id
}
