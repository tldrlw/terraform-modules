resource "aws_security_group" "api_gateway" {
  name        = "${var.APP_NAME}-api-gateway"
  description = "Security group for API Gateway VPC endpoint"
  vpc_id      = var.VPC_ID

  tags = {
    Name = "${var.APP_NAME}-api-gateway"
  }
}

resource "aws_vpc_security_group_ingress_rule" "api_gateway_ingress" {
  security_group_id            = aws_security_group.api_gateway.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.ECS_SERVICE_SECURITY_GROUP_ID
  description                  = "Allow traffic from ECS service"
  tags = {
    Name = "${var.APP_NAME}-api-gateway"
  }
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule

resource "aws_vpc_security_group_ingress_rule" "api_gateway_vpn_ingress" {
  security_group_id = aws_security_group.api_gateway.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.VPN_CIDR # Replace with the CIDR block of your Client VPN
  description       = "Allow HTTPS traffic from VPN clients"
  tags = {
    Name = "${var.APP_NAME}-api-gateway-vpn-access"
  }
}

resource "aws_vpc_security_group_egress_rule" "api_gateway_egress" {
  security_group_id = aws_security_group.api_gateway.id
  ip_protocol       = "-1"        # Allow all protocols
  cidr_ipv4         = "0.0.0.0/0" # Allow traffic to all destinations
  description       = "Allow all outbound traffic"
  tags = {
    Name = "${var.APP_NAME}-api-gateway"
  }
}

# The security group ensures that only authorized resources, such as your ECS service tasks, can access the private API Gateway endpoint.
# By default, without proper security group rules, the endpoint could potentially accept traffic from any resource in the VPC. Assigning a security group allows you to restrict this to only the ECS service or other approved resources.
# Using a dedicated security group for the API Gateway VPC endpoint makes it easier to manage and audit access policies for this specific resource.
