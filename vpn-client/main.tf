# Client VPN Endpoint
resource "aws_ec2_client_vpn_endpoint" "main" {
  client_cidr_block = var.CLIENT_CIDR # Client IP range, must not overlap with the VPC CIDR
  # Reference the managed ACM certificate
  server_certificate_arn = aws_acm_certificate_validation.server_cert_validation.certificate_arn
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.server_cert.arn # Use the root cert from ACM
  }
  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.vpn_logs.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn_log_stream.name
  }
  # Explicitly include the VPC ID for the associated security groups
  security_group_ids = [aws_security_group.client_vpn.id]
  vpc_id             = var.VPC_ID # Add this line
  split_tunnel       = false
  # Your configuration already has split_tunnel = true, meaning only traffic destined for the VPC CIDR or routes explicitly defined (e.g., 0.0.0.0/0) will go through the VPN. Other internet-bound traffic from your device will bypass the VPN and go through your normal internet connection.
  tags = {
    Name = "Client VPN Endpoint"
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "allow_all" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = var.VPC_CIDR # e.g., "10.0.0.0/16"
  authorize_all_groups   = true
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
