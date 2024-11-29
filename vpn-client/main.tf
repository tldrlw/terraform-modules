# Create a Single Private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = var.VPC_ID
  cidr_block              = "10.0.20.0/24" # Adjusted range for the single VPN subnet
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

# Associate the Subnet with the Private Route Table
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_route_table.id
}

# Client VPN Endpoint
resource "aws_ec2_client_vpn_endpoint" "main" {
  client_cidr_block = var.CLIENT_CIDR_BLOCK # Client IP range, must not overlap with the VPC CIDR
  # Reference the managed ACM certificate
  server_certificate_arn = aws_acm_certificate_validation.server_cert_validation.certificate_arn
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.server_cert.arn # Use the root cert from ACM
  }
  connection_log_options {
    enabled = false
  }
  # Explicitly include the VPC ID for the associated security groups
  security_group_ids = [aws_security_group.client_vpn.id]
  vpc_id             = var.VPC_ID # Add this line
  split_tunnel       = true
  tags = {
    Name = "Client VPN Endpoint"
  }
}

# Associate the Client VPN Endpoint with a Single Private Subnet
resource "aws_ec2_client_vpn_network_association" "main" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = aws_subnet.private.id
  depends_on             = [aws_security_group.client_vpn]
}

# resource "aws_ec2_client_vpn_route" "vpc_route" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
#   destination_cidr_block = var.VPC_CIDR # Example: "10.0.0.0/16"
#   target_vpc_subnet_id   = aws_subnet.private.id
#   lifecycle {
#     ignore_changes = [destination_cidr_block]
#   }
# }
# ^ The route for the destination CIDR 10.0.0.0/16 was automatically created by AWS when the Client VPN endpoint cvpn-endpoint-0b564f3fc6065c40e was associated with the subnet subnet-0cc7e4838a47117e3. This default route, of type Nat, ensures traffic from VPN clients is properly routed through the associated subnet. Since AWS handles this route creation automatically, defining an aws_ec2_client_vpn_route resource in Terraform would result in duplicate route errors during provisioning. This redundancy occurs because Terraform tries to create a route that already exists, leading to conflicts. Therefore, it’s unnecessary to manage this route manually in Terraform.

resource "aws_acm_certificate" "server_cert" {
  domain_name       = "vpn.${var.DOMAIN}" # Replace with your desired domain
  validation_method = "DNS"
  tags = {
    Name = "Client VPN Server Certificate"
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.server_cert.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
  zone_id = var.ROUTE_53_ZONE_ID
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "server_cert_validation" {
  certificate_arn         = aws_acm_certificate.server_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
