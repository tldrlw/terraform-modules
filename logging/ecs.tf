module "ecs_service_grafana" {
  source                      = "git::https://github.com/tldrlw/terraform-modules.git//ecs-service"
  app_name                    = "grafana-${var.ORG_NAME}"
  ecr_repo_url                = var.ECR_REPO_URL_GRAFANA
  image_tag                   = var.IMAGE_TAG_GRAFANA
  ecs_cluster_id              = var.ECS_CLUSTER_ID
  task_count                  = var.ECS_TASK_COUNT_GRAFANA
  alb_target_group_arn        = var.ALB_TARGET_GROUP_ARN_GRAFANA
  source_security_group_id    = var.SOURCE_ALB_SECURITY_GROUP_ID
  security_group_egress_cidrs = ["0.0.0.0/0"]
  subnets                     = var.PUBLIC_SUBNETS
  vpc_id                      = var.VPC_ID
  container_port              = 3000
  host_port                   = 3000
  environment_variables = [
    { name = "TEST", value = var.TEST_ENV_VAR_GRAFANA },
    # ^ comment/uncomment to get new task
    { name = "GF_SECURITY_ADMIN_USER", value = var.USERNAME_GRAFANA },
    # can shell into container with e1s and run `echo $GF_SECURITY_ADMIN_USER` to see ^
    { name = "GF_SECURITY_ADMIN_PASSWORD", value = var.PASSWORD_GRAFANA },
    { name = "GF_SERVER_PROTOCOL", value = "http" }, # Use HTTP if ALB terminates HTTPS
    { name = "GF_SERVER_HTTP_PORT", value = "3000" },
    { name = "GF_DATASOURCE_LOKI_URL", value = "${var.LOKI_URL}/loki" }
    # ^ Environment Variable (GF_DATASOURCE_LOKI_URL): While not required for provisioning, the GF_DATASOURCE_LOKI_URL environment variable can act as a backup configuration reference if you ever define the data source dynamically.
  ]
  linux_arm64 = var.LINUX_ARM_64
  # ^ set to true if building and pushing images to ECR on M-series Macs:
  # since building and pushing (locally) a custom grafana image (see infrastructure/grafana-loki/docker-push-grafana.sh)
}

resource "aws_ecs_service" "loki" {
  name                   = "loki-${var.ORG_NAME}"
  cluster                = var.ECS_CLUSTER_ID
  task_definition        = aws_ecs_task_definition.loki.arn
  desired_count          = var.ECS_TASK_COUNT_LOKI
  launch_type            = "FARGATE"
  enable_execute_command = true # Enables ECS Exec, see `data "aws_iam_policy_document" "ecs_exec_policy"` in loki-iam.tf
  network_configuration {
    subnets          = var.PUBLIC_SUBNETS           # List of subnet IDs
    security_groups  = [aws_security_group.loki.id] # Security group ID(s)
    assign_public_ip = true                         # Set to false if you don't need a public IP
  }
  load_balancer {
    target_group_arn = var.ALB_TARGET_GROUP_ARN_LOKI
    container_name   = "loki-${var.ORG_NAME}"
    container_port   = 3100
  }
}

resource "aws_ecs_task_definition" "loki" {
  family                   = "loki-${var.ORG_NAME}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # ECS execution role for logging and image pull
  task_role_arn            = aws_iam_role.ecs_task_role.arn           # Task role for application access
  memory                   = "512"
  cpu                      = "256"
  dynamic "runtime_platform" {
    for_each = var.LINUX_ARM_64 ? [1] : []
    content {
      operating_system_family = "LINUX"
      cpu_architecture        = "ARM64"
    }
  }
  container_definitions = templatefile(
    "${path.module}/task_definition.tpl.json",
    {
      app_name       = "loki-${var.ORG_NAME}"
      image          = "${var.ECR_REPO_URL_LOKI}:${var.IMAGE_TAG_LOKI}" # Replace with your custom loki image
      container_port = 3100
      host_port      = 3100
      region         = data.aws_region.current.name
      environment_variables = jsonencode(
        [
          { name = "TEST", value = var.TEST_ENV_VAR_LOKI },
          # ^ comment/uncomment to get new task
          { name = "PORT", value = "3100" },
          { name = "LOKI_CHUNK_RETENTION_DURATION", value = "168h" },
          { name = "LOKI_STORAGE_CONFIG_FILESYSTEM_DIRECTORY", value = "/data" }
        ]
      )
    }
  )
}
