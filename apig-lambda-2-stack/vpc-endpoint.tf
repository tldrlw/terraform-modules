resource "aws_vpc_endpoint" "api_gateway" {
  vpc_id              = var.VPC_ID
  service_name        = "com.amazonaws.${var.REGION}.execute-api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.PUBLIC_SUBNET_IDS
  security_group_ids  = [aws_security_group.api_gateway.id]
  private_dns_enabled = true
  # ^ requests to the standard API Gateway domain name (e.g., https://<api-id>.execute-api.us-east-1.amazonaws.com) resolve to the private IP addresses of the VPC endpoint. This allows private, secure communication within the VPC without routing through the public internet.
  tags = {
    Name = "${var.APP_NAME}-ecs-to-apig"
  }
}

# VPC Endpoint for DynamoDB
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.VPC_ID
  service_name      = "com.amazonaws.${var.REGION}.dynamodb"
  vpc_endpoint_type = "Gateway" # DynamoDB requires a Gateway VPC Endpoint
  route_table_ids = [
    aws_route_table.private.id
  ]
  tags = {
    Name = "${var.APP_NAME}-lambda-to-dynamodb"
  }
}
