# Execution Role for ECS Task Lifecycle Management
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "loki-${var.ORG_NAME}-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
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

# Policy to Allow Creating CloudWatch Log Groups
data "aws_iam_policy_document" "create_log_group_policy" {
  statement {
    actions   = ["logs:CreateLogGroup"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "create_log_group_policy" {
  name        = "loki-${var.ORG_NAME}-create-log-group-policy"
  description = "Policy to allow creating CloudWatch Log Groups"
  policy      = data.aws_iam_policy_document.create_log_group_policy.json
}

# Attach the CloudWatch Log Group Creation Policy
resource "aws_iam_role_policy_attachment" "create_log_group_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.create_log_group_policy.arn
}

##

# Task Role for Application-Level Permissions
resource "aws_iam_role" "ecs_task_role" {
  name = "loki-${var.ORG_NAME}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
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
  name   = "loki-${var.ORG_NAME}-ecs-exec-policy"
  policy = data.aws_iam_policy_document.ecs_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}
