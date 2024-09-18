# Create S3 bucket for ALB access logs
resource "aws_s3_bucket" "alb_logs" {
  count  = var.enable_logs_to_s3 ? 1 : 0
  bucket = "${var.alb_name}-alb-logs"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  count  = var.enable_logs_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  count  = var.enable_logs_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  count  = var.enable_logs_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    id = "log-expiration"
    expiration {
      days = 30 # Logs older than 30 days will be deleted
    }
    noncurrent_version_expiration {
      noncurrent_days = 90 # Expire non-current versions after 90 days if versioning is enabled
    }
    status = "Enabled"
  }
}

# Data block to define the policy using aws_iam_policy_document
data "aws_iam_policy_document" "alb_logs" {
  count = var.enable_logs_to_s3 ? 1 : 0
  statement {
    sid = "AWSLogDeliveryWrite"
    principals {
      type        = "Service"
      identifiers = ["elasticloadbalancing.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.alb_logs.arn}/*"
    ]
  }
  statement {
    sid = "AWSLogDeliveryAclCheck"
    principals {
      type        = "Service"
      identifiers = ["elasticloadbalancing.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      aws_s3_bucket.alb_logs.arn
    ]
  }
}

# S3 Bucket Policy using the data source policy document
resource "aws_s3_bucket_policy" "alb_logs" {
  count  = var.enable_logs_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.alb_logs.id
  policy = data.aws_iam_policy_document.alb_logs_policy.json
}
