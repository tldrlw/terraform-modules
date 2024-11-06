# Lambda permission for each log group
resource "aws_lambda_permission" "log_shipper" {
  statement_id  = "AllowCloudWatchLogs-${var.ORG_NAME}-${var.LOG_GROUP_NAME}"
  action        = "lambda:InvokeFunction"
  function_name = var.LAMBDA_FUNCTION_NAME
  principal     = "logs.amazonaws.com"
  source_arn    = "${var.LOG_GROUP_NAME}:*"
  # appended :* to each log group's arn. This grants permission to all log streams within the specified log group, which is necessary for the CloudWatch Logs service to invoke your λ function for any log stream.
}

# Create a CloudWatch Logs Subscription Filter
resource "aws_cloudwatch_log_subscription_filter" "log_shipper" {
  name            = "log-shipper-${var.ORG_NAME}-${var.LOG_GROUP_NAME}"
  log_group_name  = var.LOG_GROUP_NAME
  filter_pattern  = "" # Use a specific filter pattern if needed
  destination_arn = var.LAMBDA_FUNCTION_ARN
  # Ensure the permission resource is created before this filter
  depends_on = [aws_lambda_permission.log_shipper]
  # By adding depends_on, you are explicitly instructing Terraform to create the aws_lambda_permission resource before setting up the subscription filter. This ensures that the necessary permissions are in place, which resolves potential issues related to execution order.
}
