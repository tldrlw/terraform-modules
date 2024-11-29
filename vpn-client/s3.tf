# AWS S3 bucket for VPN config files
resource "aws_s3_bucket" "config_file" {
  bucket        = "${lower(var.PROJECT)}-${var.NAME}-vpn-config-file"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "config_file" {
  bucket                  = aws_s3_bucket.config_file.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_file" {
  bucket = aws_s3_bucket.config_file.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = ""
      sse_algorithm     = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_policy" "config_file" {
  bucket = aws_s3_bucket.config_file.id
  policy = data.aws_iam_policy_document.s3_vpn_config_file.json
}

data "aws_iam_policy_document" "s3_vpn_config_file" {
  statement {
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      aws_s3_bucket.config_file.arn,
      "${aws_s3_bucket.config_file.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

# AWS VPN config files generated to s3 bucket *.ovpn
resource "aws_s3_object" "vpn_config_file" {
  bucket                 = aws_s3_bucket.config_file.id
  server_side_encryption = "aws:kms"
  key                    = "${lower(var.PROJECT)}-${var.NAME}-vpn.ovpn"
  content_base64 = base64encode(<<-EOT
client
dev tun
proto ${aws_ec2_client_vpn_endpoint.main.transport_protocol}
remote ${aws_ec2_client_vpn_endpoint.main.dns_name} ${aws_ec2_client_vpn_endpoint.main.vpn_port}
remote-random-hostname
resolv-retry infinite
nobind
remote-cert-tls server
cipher AES-256-GCM
--inactive ${var.VPN_INACTIVE_PERIOD} 100
verb 3

# DNS Server for Private VPC Resolution
dhcp-option DNS 169.254.169.253

# Routing Traffic for VPC CIDR
route ${var.VPC_CIDR} 255.255.0.0

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
