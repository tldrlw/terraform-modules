data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "main" {
  name               = var.NAME
  path               = "/lambda/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role

data "aws_iam_policy_document" "dydb" {
  statement {
    effect    = "Allow"
    actions   = var.DYDB_PERMISSIONS
    resources = [var.DYDB_TABLE_ARN]
  }
}

resource "aws_iam_policy" "dydb" {
  name   = "${var.NAME}-to-dydb"
  path   = "/lambda/"
  policy = data.aws_iam_policy_document.dydb.json
}

resource "aws_iam_role_policy_attachment" "dydb" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.dydb.arn
}

data "aws_iam_policy_document" "logging" {
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

resource "aws_iam_policy" "logging" {
  name        = "${var.NAME}-logging"
  path        = "/lambda/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.logging.json
}

resource "aws_iam_role_policy_attachment" "logging" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.logging.arn
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.PRIVATE_APIG_EXECUTION_ARN}/*/*/*"
  # source_arn = "arn:aws:execute-api:${var.REGION}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.private_api.id}/*"
}

# EC2 permissions for Lambda to create and manage network interfaces
data "aws_iam_policy_document" "network_interfaces" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
    # Lambda requires specific EC2 permissions when configured to run within a VPC. The ec2:CreateNetworkInterface permission is necessary for Lambda to create a network interface (ENI) in the VPC to facilitate function execution. The ec2:DescribeNetworkInterfaces permission is required to retrieve details about the network interface during execution, and the ec2:DeleteNetworkInterface permission allows Lambda to clean up the ENI after execution to avoid resource leaks.
  }
}

resource "aws_iam_policy" "network_interfaces" {
  name        = "${var.NAME}-network-interfaces"
  path        = "/lambda/"
  description = "IAM policy for Lambda to manage network interfaces in a VPC"
  policy      = data.aws_iam_policy_document.network_interfaces.json
}

resource "aws_iam_role_policy_attachment" "network_interfaces" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.network_interfaces.arn
}
