# terraform-modules

## ecs-service

- configured for docker images built and pushed up to ECR on _M-series macs_, hence the code block below in `resource "aws_ecs_task_definition" "app"`:
  - todo: will need to add input variable and logic for instances when docker images are _not_ built on M-series macs, e.g., if this is being used in a Github build agent

```
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
```
