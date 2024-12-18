resource "aws_ecs_service" "app" {
  name                   = var.APP_NAME
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.app.arn
  desired_count          = var.AUTO_SCALING_MIN
  launch_type            = "FARGATE"
  enable_execute_command = true # Enables ECS Exec
  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.self.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.APP_NAME
    # container_port   = 80
    # ^ use for nginx:latest
    container_port = var.container_port
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.APP_NAME
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # ECS execution role for logging and image pull
  task_role_arn            = aws_iam_role.ecs_task_role.arn           # Task role for application access
  cpu                      = var.cpu
  memory                   = var.memory
  # 
  # Conditionally add the runtime_platform block based on the variable
  dynamic "runtime_platform" {
    for_each = var.linux_arm64 ? [1] : []
    content {
      operating_system_family = "LINUX"
      cpu_architecture        = "ARM64"
    }
  }
  # ^ since we could be building and pushing the Docker container on an M-series Mac: https://cloud.theodo.com/en/blog/essential-container-error-ecs
  # ^ won't need for nginx:latest since it's being pulled from Docker
  # docs on runtime platform: https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_RuntimePlatform.html
  # Use the templatefile() function to load the appropriate JSON template
  container_definitions = templatefile(
    "${path.module}/task_definition.tpl.json",
    {
      app_name              = var.APP_NAME
      image                 = "${var.ecr_repo_url}:${var.image_tag}"
      container_port        = var.container_port
      host_port             = var.host_port
      region                = data.aws_region.current.name
      environment_variables = jsonencode(var.environment_variables)
    }
  )
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
