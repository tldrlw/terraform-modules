resource "aws_ecs_task_definition" "app" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  cpu                      = "256"
  memory                   = "512"
  # ^ allowed cpu and memory combinations: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  # ^ since we're building and pushing the Docker container on an M1 Mac: https://cloud.theodo.com/en/blog/essential-container-error-ecs
  # ^ won't need for nginx:latest since it's being pulled from Docker
  container_definitions = jsonencode([{
    name = var.app_name
    # image     = "nginx:latest"
    image     = "${var.ecr_repo_url}:${var.image_tag}"
    essential = true
    portMappings = [{
      # containerPort = 80
      # hostPort      = 80
      # ^ use for nginx:latest
      containerPort = var.container_port
      hostPort      = var.host_port
    }]
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-create-group  = "true",
        awslogs-group         = "/aws/ecs/${var.app_name}",
        awslogs-region        = data.aws_region.current.name,
        awslogs-stream-prefix = "ecs"
      }
    }
    # ^ guidance for this: https://cloud.theodo.com/en/blog/essential-container-error-ecs and https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specify-log-config.html
  }])
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition

resource "aws_ecs_service" "app" {
  name            = var.app_name
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.task_count
  # ^ change to 1 or 2 when you want the task running, as opposed to 0
  launch_type = "FARGATE"
  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.app_name
    # container_port   = 80
    # ^ use for nginx:latest
    container_port = var.container_port
  }
}
