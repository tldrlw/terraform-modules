resource "aws_api_gateway_method" "main" {
  rest_api_id   = var.PRIVATE_APIG_ID
  resource_id   = var.PRIVATE_APIG_RESOURCE_ID
  http_method   = var.HTTP_METHOD
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
