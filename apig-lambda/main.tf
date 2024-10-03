data "archive_file" "lambda" {
  type       = "zip"
  source_dir = "${path.root}/${var.source_dir}"
  # ^ using `source_dir` instead of `source_file` to have external dependencies (`node_modules`) in package
  # https://developer.hashicorp.com/terraform/language/expressions/references#path-root
  output_path = "${var.function_name}.zip"
}
# https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file

resource "aws_lambda_function" "self" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = "${var.function_name}.zip"
  function_name    = var.function_name
  role             = aws_iam_role.lambda.arn
  handler          = "${var.handler_file_prefix}.lambdaHandler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs20.x"
  memory_size      = var.memory_size
  timeout          = var.timeout
  environment {
    variables = var.environment_variables
  }
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function

resource "aws_lambda_function_url" "self" {
  count              = var.function_url ? 1 : 0
  function_name      = aws_lambda_function.self.function_name
  authorization_type = var.function_url_public ? "NONE" : "AWS_IAM"
  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["Content-Type", "Authorization", "X-Amz-Date", "X-Amz-Security-Token", "date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}
# CORS settings: https://docs.aws.amazon.com/lambda/latest/dg/urls-configuration.html#urls-cors
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url

resource "aws_lambda_permission" "allow_public_invoke_function_url" {
  count                  = var.function_url && var.function_url_public ? 1 : 0
  statement_id           = "AllowPublicInvokeFunctionUrl"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.self.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}
# ^ To allow unauthenticated (public) access to your Lambda function URL when the authorization_type is set to "NONE", you need to add a resource-based policy to your Lambda function that grants the lambda:InvokeFunctionUrl permission to all principals (*). This is required to allow public access since there is no authentication method when authorization_type is set to "NONE".
