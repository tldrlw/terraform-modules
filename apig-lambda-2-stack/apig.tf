resource "aws_api_gateway_rest_api" "private" {
  name              = "${var.APP_NAME}-private"
  put_rest_api_mode = "merge"
  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [aws_vpc_endpoint.api_gateway.id]
  }
}

# If set to PRIVATE recommend to set put_rest_api_mode = merge to not cause the endpoints and associated Route53 records to be deleted.
# ^ https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api#endpoint_configuration
# A private API endpoint is an API endpoint that can only be accessed from your Amazon Virtual Private Cloud (VPC) using an interface VPC endpoint, which is an endpoint network interface (ENI) that you create in your VPC.
# ^ https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-api-endpoint-types.html
# Private REST APIs in API Gateway: https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-private-apis.html
# Create a private API: https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-private-api-create.html

resource "aws_api_gateway_resource" "self" {
  for_each    = toset(var.APIG_RESOURCES) # Ensure unique resource paths
  rest_api_id = aws_api_gateway_rest_api.private.id
  parent_id   = aws_api_gateway_rest_api.private.root_resource_id
  path_part   = each.value
}

resource "aws_api_gateway_deployment" "private" {
  depends_on  = [aws_api_gateway_rest_api_policy.private_api_policy]
  rest_api_id = aws_api_gateway_rest_api.private.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.private))
  }
  lifecycle {
    create_before_destroy = true
  }
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment

resource "aws_api_gateway_stage" "main" {
  rest_api_id   = aws_api_gateway_rest_api.private.id
  stage_name    = var.APIG_STAGE_NAME
  deployment_id = aws_api_gateway_deployment.private.id
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage
