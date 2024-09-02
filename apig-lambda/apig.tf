# Variables
variable "enable_cors" {
  description = "Set to true to enable CORS for this method."
  type        = bool
  default     = false
}

resource "aws_api_gateway_method" "self" {
  rest_api_id   = var.REST_api_id
  resource_id   = var.REST_api_resource_id
  http_method   = var.REST_method
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.REST_api_authorizer_id
}

resource "aws_api_gateway_method_response" "two_hundred" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = var.REST_api_id
  resource_id = var.REST_api_resource_id
  http_method = aws_api_gateway_method.self.http_method
  status_code = "200"
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

resource "aws_lambda_permission" "self" {
  statement_id  = "AllowExecutionFromAPIGatewayMyAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.self.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.REST_api_execution_arn}/*/*/*"
}

resource "aws_api_gateway_integration_response" "self" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = var.REST_api_id
  resource_id = var.REST_api_resource_id
  http_method = aws_api_gateway_method.self.http_method
  status_code = aws_api_gateway_method_response.two_hundred[0].status_code
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

# Add the OPTIONS method conditionally for CORS
resource "aws_api_gateway_method" "options" {
  count         = var.enable_cors ? 1 : 0
  rest_api_id   = var.REST_api_id
  resource_id   = var.REST_api_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = var.REST_api_id
  resource_id = var.REST_api_resource_id
  http_method = aws_api_gateway_method.options[0].http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "options" {
  count                = var.enable_cors ? 1 : 0
  rest_api_id          = var.REST_api_id
  resource_id          = var.REST_api_resource_id
  http_method          = aws_api_gateway_method.options[0].http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "options" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = var.REST_api_id
  resource_id = var.REST_api_resource_id
  http_method = aws_api_gateway_method.options[0].http_method
  status_code = aws_api_gateway_method_response.options[0].status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}
