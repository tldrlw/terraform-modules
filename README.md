# terraform-modules

## apig-lambda

- Added variable `enable_cors` to provision additional APIG config if this is needed, e.g., next.js app is making calls to Lambda from client components as opposed to server-side components

## apig-lambda-2

- 11/26/24
- This Lambda module provisions secure and tightly restricted Lambda functions within private subnets, ensuring they are isolated from public internet access. The Lambda functions are accessible exclusively through a private REST API Gateway endpoint, which enforces secure communication from an ECS task operating within the same VPC. Additionally, the Lambda functions interact with DynamoDB through a VPC Gateway Endpoint, eliminating the need for a NAT Gateway. This configuration ensures a highly secure, private, and cost-efficient architecture, where the Lambda functions are shielded from unauthorized access and can communicate seamlessly with both the ECS task and DynamoDB.
- This setup significantly reduces latency by ensuring that the ECS task and the Lambda function both operate within the same VPC, enabling direct and fast communication through the private API Gateway endpoint. Additionally, the Lambda function communicates with DynamoDB using a VPC Gateway Endpoint, keeping traffic entirely within the AWS private network and avoiding the overhead of routing through a NAT Gateway or the public internet. This architecture is not only faster but also more secure compared to alternatives such as using Lambda function URLs, which would involve public communication and potentially higher latency due to internet routing. By keeping all interactions within the VPC, the solution achieves both enhanced performance and robust security.

## apig-lambda-2-stack

- 11/27/24
- includes required infrastructure for `apig-lambda-2` instantiations
- The term “stack” is an ideal choice for the module name because it effectively conveys the purpose and functionality of the module. It is descriptive, indicating that the module bundles together all the necessary resources—such as API Gateway, VPC endpoints, private subnets, and other infrastructure—required to support a Lambda function.
  - The term also highlights the modular nature of the setup, as it allows for reusable and composable infrastructure components that can be instantiated multiple times for different use cases. Furthermore, _“stack” implies scalability, suggesting that the module is designed to grow or adapt by including additional resources as requirements evolve._ This makes the name intuitive, flexible, and aligned with best practices in infrastructure as code.
- We moved the API Gateway deployment and stage out of the lambda_stack module to avoid a cyclical dependency and ensure flexibility as additional Lambda module instances are added. The lambda_stack module manages the API Gateway’s resources, such as REST APIs, resources, and VPC integrations, which are prerequisites for the methods and integrations created dynamically by Lambda modules.
  - By centralizing the deployment and stage in the root module, we allow the deployment to depend explicitly on the outputs of multiple Lambda modules (e.g., methods and integrations). This approach ensures that the deployment captures all changes, avoids dependency conflicts, and provides scalability, as new Lambda modules can be seamlessly integrated without modifying the lambda_stack module.

## app-load-balancer

- To see this being implemented, check out https://github.com/tldrlw/blog-tldrlw/blob/main/infrastructure/alb.tf

- Good guide on setting up Security Groups for ECS: https://medium.com/the-cloud-journal/ecs-fargate-with-alb-deployment-using-terraform-part-3-eb52309fdd8f

- 9/18/2024, added configuration for ALB logging to S3, to use set `enable_logs_to_s3 = true`

- 9/29/2024, added support for single ALB to have multiple listener rules and target groups to support multiple apps of different subdomains, e.g., using a single ALB to route traffic to either blog.tldrlw.com or monza.tldrlw.com - benefit to this approach as opposed to 1 ALB : 1 app is cost savings, especially if multiple apps are running in the same region

## app-load-balancer-2

- This module sets up an Application Load Balancer (ALB) that routes traffic from multiple domains or hostnames (e.g., hello.com and world.com) to a single target group connected to an ECS service. It creates a single HTTPS listener on port 443, supports multiple domain-specific SSL certificates using AWS ALB Listener Certificates, and uses listener rules to route traffic based on the host_header condition. This ensures all traffic from the specified domains is securely directed to the same ECS service backend while maintaining flexibility for future domain additions.
  - 11/22/204 - for radiotodaydhaka.com and radiotodaybd.fm (domain registered in GoDaddy, route53 hosted zone nameservers all added to GoDaddy) to serve traffic to the ecs service defined in repo `radiotodaydhaka`

## ecs-service

- 10/30/24, added functionality to be able to shell into the container, e.g., using e1s, meant adding additional IAM policies, now IAM policies are split up into a task role and an execution role for better security and maintainability, task role allows for shelling into container and access to s3 for example, whereas execution role allows logging and being able to pull container images

- To see this being implemented, check out https://github.com/tldrlw/blog-tldrlw/blob/main/infrastructure/ecs.tf

## logging

- 11/6/24, will need to have loki and grafana images built and pushed to ECR prior to instantiating module, calling module will also need to have ECR repos (for loki and grafana) managed prior
  - currently set up to have a single λ function push multiple cloudwatch log groups to loki, but for scaling, could explore having multiple λ functions in the future
  - assumes that this 'logging' module instantiation is for an entire organization, i.e., logging will cover all infrastructure components that are part of `tldrlw`, meaning all apps (e.g., monza, blog, etc.) and their associated components like λ functions can/will be included in this logging setup

## vpn-client

- got some help from https://registry.terraform.io/modules/babicamir/vpn-client/aws/latest

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
