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

resource "aws_iam_role_policy_attachment" "attach_create_log_group_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.create_log_group_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
