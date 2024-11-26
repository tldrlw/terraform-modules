data "archive_file" "lambda" {
  type       = "zip"
  source_dir = "${path.root}/${var.SOURCE_DIR}"
  # ^ using `source_dir` instead of `source_file` to have external dependencies (`node_modules`) in package
  # https://developer.hashicorp.com/terraform/language/expressions/references#path-root
  output_path = "${var.NAME}.zip"
}
# https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file

resource "aws_lambda_function" "main" {
  filename         = "${var.NAME}.zip"
  function_name    = var.NAME
  role             = aws_iam_role.main.arn
  handler          = "${var.HANDLER_FILE_PREFIX}.lambdaHandler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs20.x"
  memory_size      = var.MEMORY_SIZE
  timeout          = var.TIMEOUT
  environment {
    variables = var.ENV_VARS
  }
  vpc_config {
    subnet_ids         = var.PRIVATE_SUBNET_IDS
    security_group_ids = [aws_security_group.main.id]
  }
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
