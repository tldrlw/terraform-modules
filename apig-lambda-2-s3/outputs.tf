output "private_apig_method_id" {
  value = aws_api_gateway_method.main.id
}

output "private_apig_integration_uri" {
  value = aws_api_gateway_integration.main.uri
}
