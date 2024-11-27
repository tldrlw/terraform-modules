# Security Group for Lambda
resource "aws_security_group" "main" {
  depends_on = [ aws_lambda_function.main ]
  name        = "${var.NAME}-lambda"
  description = "Security group for Lambda functions"
  vpc_id      = var.VPC_ID
  tags = {
    Name = "${var.NAME}-lambda"
  }
}

# Ingress Rule: Allow traffic from API Gateway
resource "aws_vpc_security_group_ingress_rule" "main" {
  security_group_id            = aws_security_group.main.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.APIG_SECURITY_GROUP_ID
  description                  = "Allow traffic from API Gateway"
  tags = {
    Name = "${var.NAME}-lambda"
  }
}

# Egress Rule: Allow traffic to DynamoDB VPC Endpoint
resource "aws_vpc_security_group_egress_rule" "main" {
  security_group_id = aws_security_group.main.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  prefix_list_id    = var.VPC_ENDPOINT_DYDB_PREFIX_LIST_ID
  description       = "Allow HTTPS traffic to DynamoDB via VPC Endpoint"
  tags = {
    Name = "${var.NAME}-lambda"
  }
}
