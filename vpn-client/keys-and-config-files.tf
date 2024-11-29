# TLS certificate and key
resource "tls_private_key" "client" {
  algorithm = "RSA"
}

resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.client.private_key_pem
  subject {
    common_name  = "${var.PROJECT}.${var.ENV}.vpn.${each.value}-client"
    organization = var.PROJECT
  }
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem      = tls_cert_request.client.cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 87600
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

# AWS ACM certificate
resource "aws_acm_certificate" "client" {
  private_key       = tls_private_key.client.private_key_pem
  certificate_body  = tls_locally_signed_cert.client.cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem
}

# AWS VPN config files generated to s3 bucket *.ovpn
resource "aws_s3_object" "vpn-config-file" {
  bucket                 = aws_s3_bucket.vpn-config-files.id
  server_side_encryption = "aws:kms"
  key                    = "${each.value}-${lower(var.PROJECT)}-${var.ENV}-vpn.ovpn"
  content_base64 = base64encode(<<-EOT
client
dev tun
proto ${aws_ec2_client_vpn_endpoint.vpn-client.transport_protocol}
remote ${aws_ec2_client_vpn_endpoint.vpn-client.id}.prod.clientvpn.${data.aws_region.current.name}.amazonaws.com ${aws_ec2_client_vpn_endpoint.vpn-client.vpn_port}
remote-random-hostname
resolv-retry infinite
nobind
remote-cert-tls server
cipher AES-256-GCM
--inactive ${var.VPN_INACTIVE_PERIOD} 100
verb 3

<ca>
${aws_ssm_parameter.vpn_ca_cert.value}
</ca>

reneg-sec 0

<cert>
${aws_ssm_parameter.vpn_client_cert.value}
</cert>

<key>
${aws_ssm_parameter.vpn_client_key.value}
</key>
    EOT
  )
}

# AWS SSM records
resource "aws_ssm_parameter" "vpn_client_key" {
  name        = "/${var.PROJECT}/${var.ENV}/acm/vpn/client_key"
  description = "VPN ${each.value} client key"
  type        = "SecureString"
  value       = tls_private_key.client.private_key_pem
}

resource "aws_ssm_parameter" "vpn_client_cert" {
  name        = "/${var.PROJECT}/${var.ENV}/acm/vpn/client_cert"
  description = "VPN ${each.value} client cert"
  type        = "SecureString"
  value       = tls_locally_signed_cert.client.cert_pem
}
