resource "aws_api_gateway_method" "method" {
  rest_api_id   = var.PRIVATE_APIG_REST_API_ID
  resource_id   = var.PRIVATE_APIG_REST_API_RESOURCE_ID
  http_method   = var.HTTP_METHOD
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = var.PRIVATE_APIG_REST_API_ID
  resource_id             = var.PRIVATE_APIG_REST_API_RESOURCE_ID
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.main.invoke_arn
}
