output "private_apig_resource_ids" {
  value = { for resource, details in aws_api_gateway_resource.self : resource => details.id }
}
# {
#   "insights"  = "resource-id-for-insights"
#   "analytics" = "resource-id-for-analytics"
#   "reports"   = "resource-id-for-reports"
# }

output "private_apig_resource_paths" {
  value = { for resource, details in aws_api_gateway_resource.self : resource => details.path }
}

output "private_apig_security_group_id" {
  value = aws_security_group.api_gateway.id
}

output "private_apig_execution_arn" {
  value = aws_api_gateway_rest_api.private.execution_arn
}

output "private_apig_id" {
  value = aws_api_gateway_rest_api.private.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}
# [
#   "subnet-12345",
#   "subnet-67890",
#   "subnet-abcde"
# ]

output "vpc_endpoint_dydb_prefix_list_id" {
  value = aws_vpc_endpoint.dynamodb.prefix_list_id
}
