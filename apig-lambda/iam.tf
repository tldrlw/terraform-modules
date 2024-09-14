# assume role policy
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

# role
resource "aws_iam_role" "lambda" {
  name               = var.function_name
  path               = "/lambda/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role

# s3 policy
data "aws_iam_policy_document" "lambda_to_s3" {
  count = var.is_s3 == true ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = var.s3_bucket_permissions
    resources = [var.s3_bucket_arn, "${var.s3_bucket_arn}/*"]
    # important to have a duplicate of the arn but with the wildcard path as a suffix, otherwise, despite having the correct permissions, you'll get an "AccessDeniedException" error
    # ^ https://github.com/tgroshon/amplify2terraform/blob/d080dd55e1aefb9de8eee315c9bac85cdf93803f/terraform/api.tf#L167
  }
}

resource "aws_iam_policy" "lambda_to_s3" {
  count  = var.is_s3 == true ? 1 : 0
  name   = "${var.function_name}-to-s3"
  path   = "/lambda/"
  policy = data.aws_iam_policy_document.lambda_to_s3[count.index].json
}

resource "aws_iam_role_policy_attachment" "lambda_to_s3" {
  count      = var.is_s3 == true ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_to_s3[count.index].arn
}

# dydb policy
data "aws_iam_policy_document" "lambda_to_dydb" {
  count = var.is_dydb == true ? 1 : 0
  statement {
    effect  = "Allow"
    actions = var.dydb_table_permissions
    # Use concat to conditionally include the GSI ARN
    resources = concat(
      [var.dydb_table_arn],                                                                                                     # Always include table ARN
      var.global_secondary_index_name != "" ? [format("%s/index/%s", var.dydb_table_arn, var.global_secondary_index_name)] : [] # Conditionally include GSI ARN
    )
  }
}

resource "aws_iam_policy" "lambda_to_dydb" {
  count  = var.is_dydb == true ? 1 : 0
  name   = "${var.function_name}-to-dydb"
  path   = "/lambda/"
  policy = data.aws_iam_policy_document.lambda_to_dydb[count.index].json
}

resource "aws_iam_role_policy_attachment" "lambda_to_dydb" {
  count      = var.is_dydb == true ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_to_dydb[count.index].arn
}

# cloudwatch policy
# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "lambda_logging" {
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

resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.function_name}-logging"
  path        = "/lambda/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
