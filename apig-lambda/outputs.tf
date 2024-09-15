output "function_url" {
  value = one(aws_lambda_function_url.self[*].function_url)
}
# https://developer.hashicorp.com/terraform/language/functions/one
# This is a specialized function intended for the common situation where a conditional item is represented as either a zero- or one-element list, where a module author wishes to return a single value that might be null instead.

output "arn" {
  value = aws_lambda_function.self.arn
}

output "apig_method_id" {
  value = length(aws_api_gateway_method.self) > 0 ? aws_api_gateway_method.self[0].id : null
}

output "apig_integration_id" {
  value = length(aws_api_gateway_integration.self) > 0 ? aws_api_gateway_integration.self[0].id : null
}