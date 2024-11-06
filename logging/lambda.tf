# Security Group for the λ function
resource "aws_security_group" "log_shipper" {
  vpc_id                 = var.VPC_ID
  name                   = "log-shipper-${var.ORG_NAME}"
  description            = "Security group for log-shipper-${var.ORG_NAME} λ function"
  revoke_rules_on_delete = true
}

# Egress rule to allow all outbound traffic (default behavior for λ functions)
resource "aws_security_group_rule" "log_shipper_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.log_shipper.id
  cidr_blocks       = ["0.0.0.0/0"]
}


data "archive_file" "log_shipper" {
  type        = "zip"
  source_dir  = "${path.module}/lambda" # Path to your λ function code
  output_path = "${path.module}/log-shipper.zip"
}

resource "aws_lambda_function" "log_shipper" {
  function_name    = "log-shipper-${var.ORG_NAME}"
  role             = aws_iam_role.log_shipper.arn
  handler          = "log-shipper.handler" # Specify the handler
  source_code_hash = data.archive_file.log_shipper.output_base64sha256
  runtime          = "nodejs20.x" # Use Node.js 18.x or later
  timeout          = 30
  # Use the zipped file created by the archive_file resource
  filename = data.archive_file.log_shipper.output_path
  environment {
    variables = {
      LOKI_URL = "${var.LOKI_URL}/loki/api/v1/push"
    }
  }
  vpc_config {
    subnet_ids         = var.PRIVATE_SUBNETS
    security_group_ids = [aws_security_group.log_shipper.id]
  }
}

# IAM Role for λ function
resource "aws_iam_role" "log_shipper" {
  name = "log-shipper-${var.ORG_NAME}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Custom IAM Policy for λ function to make HTTP requests
resource "aws_iam_policy" "log_shipper" {
  name        = "log-shipper-${var.ORG_NAME}"
  description = "Policy for log-shipper-${var.ORG_NAME} λ function to send HTTP requests"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:AttachNetworkInterface"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the Custom IAM Policy to the Role
resource "aws_iam_role_policy_attachment" "log_shipper" {
  role       = aws_iam_role.log_shipper.name
  policy_arn = aws_iam_policy.log_shipper.arn
}

# cloudwatch policy
# See also the following AWS managed policy: AWSλBasicExecutionRole
data "aws_iam_policy_document" "log_shipper_logging" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function#cloudwatch-logging-and-permissions

resource "aws_iam_policy" "log_shipper_logging" {
  name        = "log-shipper-${var.ORG_NAME}-logging"
  path        = "/lambda/"
  description = "IAM policy for logging from the log-shipper-${var.ORG_NAME} λ function"
  policy      = data.aws_iam_policy_document.log_shipper_logging.json
}

resource "aws_iam_role_policy_attachment" "log_shipper_logging" {
  role       = aws_iam_role.log_shipper.name
  policy_arn = aws_iam_policy.log_shipper_logging.arn
}

module "log_group_subscriptions" {
  for_each             = toset(var.LOG_GROUPS)
  source               = "./log-group-subscription"
  LOG_GROUP_NAME       = each.value
  LAMBDA_FUNCTION_NAME = aws_lambda_function.log_shipper.function_name
  LAMBDA_FUNCTION_ARN  = aws_lambda_function.log_shipper.arn
  ORG_NAME             = var.ORG_NAME
}
