resource "aws_cloudwatch_log_group" "vpn_logs" {
  name              = "/aws/vpn/vpn-log-group"
  retention_in_days = 30 # Adjust retention period as needed
  tags = {
    Name = "VPN Logs"
  }
}

resource "aws_cloudwatch_log_stream" "vpn_log_stream" {
  name           = "vpn-log-stream"
  log_group_name = aws_cloudwatch_log_group.vpn_logs.name
}
