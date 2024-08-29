output "function_url" {
  value = one(aws_lambda_function_url.self[*].function_url)
}
# https://developer.hashicorp.com/terraform/language/functions/one
# This is a specialized function intended for the common situation where a conditional item is represented as either a zero- or one-element list, where a module author wishes to return a single value that might be null instead.

output "arn" {
  value = aws_lambda_function.self.arn
}

output "apig_method_id" {
  value = aws_api_gateway_method.self.id
}

output "apig_integration_id" {
  value = aws_api_gateway_integration.self.id
}
