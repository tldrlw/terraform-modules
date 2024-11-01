# Execution Role for ECS Task Lifecycle Management
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-ecs-execution-role"
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

# Attach Amazon ECS Task Execution Role Policy for Image Pull and Log Permissions
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Policy to Allow Creating CloudWatch Log Groups (optional)
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

# Attach the CloudWatch Log Group Creation Policy
resource "aws_iam_role_policy_attachment" "attach_create_log_group_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.create_log_group_policy.arn
}

# Task Role for Application-Level Permissions
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.app_name}-ecs-task-role"
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

# S3 Access Policy for Application
data "aws_iam_policy_document" "s3_access_policy_doc" {
  count = var.s3_access ? 1 : 0 # Attach only if `var.s3_access` is true
  statement {
    actions   = ["s3:GetObject"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.s3_bucket}/*"] # Access all files in the bucket
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  count       = var.s3_access ? 1 : 0 # Attach only if `var.s3_access` is true
  name        = "${var.app_name}-s3-access-policy"
  description = "Policy to allow access to all files in the S3 bucket"
  policy      = data.aws_iam_policy_document.s3_access_policy_doc[0].json
}

# Conditionally Attach S3 Access Policy to Task Role
resource "aws_iam_role_policy_attachment" "attach_s3_access_policy" {
  count      = var.s3_access ? 1 : 0 # Attach only if `var.s3_access` is true
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.s3_access_policy[0].arn
}

# ECS Exec Policy for Application
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
  name   = "${var.app_name}-ecs-exec-policy"
  policy = data.aws_iam_policy_document.ecs_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}
