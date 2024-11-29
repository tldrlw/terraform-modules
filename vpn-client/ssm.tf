resource "aws_ssm_parameter" "vpn_ca_key" {
  name        = "/${var.PROJECT}/${var.NAME}/acm/vpn/ca_key"
  description = "VPN CA key"
  type        = "SecureString"
  value       = tls_private_key.ca.private_key_pem

}
resource "aws_ssm_parameter" "vpn_ca_cert" {
  name        = "/${var.PROJECT}/${var.NAME}/acm/vpn/ca_cert"
  description = "VPN CA cert"
  type        = "SecureString"
  value       = tls_self_signed_cert.ca.cert_pem
}

resource "aws_ssm_parameter" "vpn_client_key" {
  name        = "/${var.PROJECT}/${var.NAME}/acm/vpn/client_key"
  description = "VPN client key"
  type        = "SecureString"
  value       = tls_private_key.client.private_key_pem
}

resource "aws_ssm_parameter" "vpn_client_cert" {
  name        = "/${var.PROJECT}/${var.NAME}/acm/vpn/client_cert"
  description = "VPN client cert"
  type        = "SecureString"
  value       = tls_locally_signed_cert.client.cert_pem
}

resource "aws_ssm_parameter" "vpn_server_key" {
  name        = "/${var.PROJECT}/${var.NAME}/acm/vpn/server_key"
  description = "VPN server key"
  type        = "SecureString"
  value       = tls_private_key.server.private_key_pem
}

resource "aws_ssm_parameter" "vpn_server_cert" {
  name        = "/${var.PROJECT}/${var.NAME}/acm/vpn/server_cert"
  description = "VPN server cert"
  type        = "SecureString"
  value       = tls_locally_signed_cert.server.cert_pem
}
