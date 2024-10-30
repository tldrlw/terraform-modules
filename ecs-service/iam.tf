# Define the IAM role for the ECS task
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.app_name}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Policy to allow creating CloudWatch Log Groups
data "aws_iam_policy_document" "create_log_group_policy_doc" {
  statement {
    actions   = ["logs:CreateLogGroup"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "create_log_group_policy" {
  name        = "${var.app_name}-create-log-group-policy"
  description = "Policy to allow creating CloudWatch Log Groups"
  policy      = data.aws_iam_policy_document.create_log_group_policy_doc.json
}

# Attach CloudWatch policy
resource "aws_iam_role_policy_attachment" "attach_create_log_group_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.create_log_group_policy.arn
}

# Attach Amazon ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# S3 Access Policy Document for All Files in the Bucket
data "aws_iam_policy_document" "s3_access_policy_doc" {
  statement {
    actions   = ["s3:GetObject"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::tldrlw-ecs-config-files/*"] # Access all files in the bucket
  }
}

# S3 Access Policy Resource
resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.app_name}-s3-access-policy"
  description = "Policy to allow access to all files in the S3 bucket"
  policy      = data.aws_iam_policy_document.s3_access_policy_doc.json
}

# Conditionally Attach S3 Access Policy
resource "aws_iam_role_policy_attachment" "attach_s3_access_policy" {
  count      = var.command != null ? 1 : 0 # Attach only if `command` is not null
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# ECS exec
data "aws_iam_policy_document" "ecs_exec_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_exec_policy" {
  name   = "ECSExecPolicy"
  policy = data.aws_iam_policy_document.ecs_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attachment" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}

data "aws_iam_policy_document" "ecs_exec_initiator_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:ExecuteCommand",
      "ssm:StartSession",
      "ssm:SendCommand",
      "ssm:DescribeSessions",
      "ssm:GetConnectionStatus",
      "ssm:GetCommandInvocation"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_exec_initiator_policy" {
  name   = "ECSExecInitiatorPolicy"
  policy = data.aws_iam_policy_document.ecs_exec_initiator_policy.json
}

resource "aws_iam_user_policy_attachment" "ecs_exec_initiator_attachment" {
  user       = data.aws_iam_user.initiating_user.user_name # Reference the IAM user from the data source
  policy_arn = aws_iam_policy.ecs_exec_initiator_policy.arn
}
