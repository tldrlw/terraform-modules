resource "aws_api_gateway_method" "self" {
  rest_api_id   = var.REST_api_id
  resource_id   = var.REST_api_resource_id
  http_method   = var.REST_method
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.REST_api_authorizer_id
}

resource "aws_api_gateway_method_response" "two_hundred" {
  rest_api_id = var.REST_api_id
  resource_id = var.REST_api_resource_id
  http_method = aws_api_gateway_method.self.http_method
  status_code = "200"
  //cors section
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "self" {
  rest_api_id             = var.REST_api_id
  resource_id             = var.REST_api_resource_id
  http_method             = aws_api_gateway_method.self.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.self.invoke_arn
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration#argument-reference

resource "aws_lambda_permission" "podcasts_post" {
  statement_id  = "AllowExecutionFromAPIGatewayMyAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.self.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.REST_api_execution_arn}/*/*/*"
}

resource "aws_api_gateway_integration_response" "self" {
  rest_api_id = var.REST_api_id
  resource_id = var.REST_api_resource_id
  http_method = aws_api_gateway_method.self.http_method
  status_code = aws_api_gateway_method_response.two_hundred.status_code
  //cors
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [
    aws_api_gateway_method.self,
    aws_api_gateway_integration.self
  ]
}
