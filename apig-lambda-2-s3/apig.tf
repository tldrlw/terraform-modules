# Main POST Method (Invokes the Lambda)
resource "aws_api_gateway_method" "main" {
  rest_api_id   = var.PRIVATE_APIG_ID
  resource_id   = var.PRIVATE_APIG_RESOURCE_ID
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id             = var.PRIVATE_APIG_ID
  resource_id             = var.PRIVATE_APIG_RESOURCE_ID
  http_method             = aws_api_gateway_method.main.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.main.invoke_arn
}

resource "aws_api_gateway_method_response" "main_200" {
  rest_api_id = var.PRIVATE_APIG_ID
  resource_id = var.PRIVATE_APIG_RESOURCE_ID
  http_method = aws_api_gateway_method.main.http_method
  status_code = "200"
  # Enable CORS headers in the response
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "main_200" {
  rest_api_id = var.PRIVATE_APIG_ID
  resource_id = var.PRIVATE_APIG_RESOURCE_ID
  http_method = aws_api_gateway_method.main.http_method
  status_code = aws_api_gateway_method_response.main_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [
    aws_api_gateway_method.main,
    aws_api_gateway_integration.main
  ]
}

# OPTIONS Method (for CORS Preflight Requests)
resource "aws_api_gateway_method" "options" {
  rest_api_id   = var.PRIVATE_APIG_ID
  resource_id   = var.PRIVATE_APIG_RESOURCE_ID
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = var.PRIVATE_APIG_ID
  resource_id = var.PRIVATE_APIG_RESOURCE_ID
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = var.PRIVATE_APIG_ID
  resource_id = var.PRIVATE_APIG_RESOURCE_ID
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "options_200" {
  rest_api_id = var.PRIVATE_APIG_ID
  resource_id = var.PRIVATE_APIG_RESOURCE_ID
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  # Ensure that this integration response is only created after the method and integration are ready
  depends_on = [
    aws_api_gateway_method.main,
    aws_api_gateway_integration.options
  ]
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.PRIVATE_APIG_EXECUTION_ARN}/*/*/*"
  # source_arn = "arn:aws:execute-api:${var.REGION}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.private_api.id}/*"
}
