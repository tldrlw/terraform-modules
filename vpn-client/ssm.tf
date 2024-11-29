# AWS SSM records
resource "aws_ssm_parameter" "vpn_client_key" {
  name        = "/${var.PROJECT}/${var.NAME}/acm/vpn/client_key"
  description = "VPN ${each.value} client key"
  type        = "SecureString"
  value       = tls_private_key.client.private_key_pem
}

resource "aws_ssm_parameter" "vpn_client_cert" {
  name        = "/${var.PROJECT}/${var.NAME}/acm/vpn/client_cert"
  description = "VPN ${each.value} client cert"
  type        = "SecureString"
  value       = tls_locally_signed_cert.client.cert_pem
}
