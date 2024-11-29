# AWS S3 bucket for VPN config files
resource "aws_s3_bucket" "config_file" {
  bucket        = "${lower(var.PROJECT)}-${var.ENV}-vpn-config-file"
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
  policy = data.aws_iam_policy_document.config_file.json
}

data "aws_iam_policy_document" "s3_vpn_config_file" {
  statement {
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      "arn:aws:s3:::${lower(var.PROJECT)}-${var.ENV}-vpn-config-files",
      "arn:aws:s3:::${lower(var.PROJECT)}-${var.ENV}-vpn-config-files/*"
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
