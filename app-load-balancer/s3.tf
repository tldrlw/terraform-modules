# Create S3 bucket for ALB access logs
resource "aws_s3_bucket" "alb_logs" {
  count  = var.enable_logs_to_s3 ? 1 : 0
  bucket = "${var.alb_name}-alb-logs"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  count  = var.enable_logs_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[count.index].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
      # ^ same as "Server-side encryption with Amazon S3 managed keys (SSE-S3)"
      # ALB docs: The only server-side encryption option that's supported is Amazon S3-managed keys (SSE-S3).
      # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
    }
  }
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  count  = var.enable_logs_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  count  = var.enable_logs_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[count.index].id
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

# Define a dynamic principal based on the value of enable_logs_to_s3_new_regions
locals {
  principal_type       = var.enable_logs_to_s3_new_regions ? "Service" : "AWS"
  principal_identifier = var.enable_logs_to_s3_new_regions ? "logdelivery.elasticloadbalancing.amazonaws.com" : "arn:aws:iam::${var.elb_account_id}:root"
}

# Data block to define the policy using aws_iam_policy_document
data "aws_iam_policy_document" "alb_logs" {
  count = var.enable_logs_to_s3 ? 1 : 0
  # Allow Elastic Load Balancer to write logs to S3
  statement {
    sid = "AWSLogDeliveryWrite"
    principals {
      type        = local.principal_type         # Use dynamic principal type
      identifiers = [local.principal_identifier] # Use dynamic principal identifier
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.alb_logs[count.index].arn}/*" # Access to bucket objects
    ]
  }
  # ^ look at step 2 for the policies, they vary based on region
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
  # Allow Elastic Load Balancer to check the bucket ACL
  statement {
    sid = "AWSLogDeliveryAclCheck"
    principals {
      type        = local.principal_type         # Use dynamic principal type
      identifiers = [local.principal_identifier] # Use dynamic principal identifier
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      aws_s3_bucket.alb_logs[count.index].arn # Access to bucket ACL
    ]
  }
}

# S3 Bucket Policy using the data source policy document
resource "aws_s3_bucket_policy" "alb_logs" {
  count  = var.enable_logs_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[count.index].id
  policy = data.aws_iam_policy_document.alb_logs[count.index].json
}
