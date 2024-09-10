# terraform-modules

## apig-lambda

- Added variable `enable_cors` to provision additional APIG config if this is needed, e.g., next.js app is making calls to Lambda from client components as opposed to server-side components

## app-load-balancer

- Good guide on setting up Security Groups for ECS: https://medium.com/the-cloud-journal/ecs-fargate-with-alb-deployment-using-terraform-part-3-eb52309fdd8f

## ecs-service

### future additions:

- **DONE**, added `linux_arm64` boolean variable

  - configured for docker images built and pushed up to ECR on _M-series macs_, hence the code block below in `resource "aws_ecs_task_definition" "app"`:
    - todo: will need to add input variable and logic for instances when docker images are _not_ built on M-series macs, e.g., if this is being used in a Github build agent

  ```
    runtime_platform {
      operating_system_family = "LINUX"
      cpu_architecture        = "ARM64"
    }
  ```
