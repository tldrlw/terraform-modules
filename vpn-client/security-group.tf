resource "aws_security_group" "client_vpn" {
  name        = "client-vpn-sg"
  description = "Security group for Client VPN"
  vpc_id      = var.VPC_ID
  tags = {
    Name = "Client VPN Security Group"
  }
}

# Ingress Rule for Client VPN (Allow HTTPS traffic)
resource "aws_vpc_security_group_ingress_rule" "client_vpn_ingress" {
  security_group_id = aws_security_group.client_vpn.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.TRUSTED_CIDR
  description       = "Allow HTTPS traffic from VPN clients"
}

# Egress Rule for Client VPN (Allow all outbound traffic)
resource "aws_vpc_security_group_egress_rule" "client_vpn_egress" {
  security_group_id = aws_security_group.client_vpn.id
  ip_protocol       = "-1"        # All protocols
  cidr_ipv4         = "0.0.0.0/0" # Allow all outbound traffic
  description       = "Allow all outbound traffic"
}

# Ingress Rule for VPN Client-to-VPC Traffic
resource "aws_vpc_security_group_ingress_rule" "vpn_client_to_vpc" {
  security_group_id = aws_security_group.client_vpn.id
  ip_protocol       = "-1" # Allow all protocols
  cidr_ipv4         = var.CLIENT_CIDR
  description       = "Allow all protocols from VPN clients"
}
