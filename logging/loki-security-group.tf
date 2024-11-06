# Security Group for Loki ECS Container
resource "aws_security_group" "loki" {
  vpc_id                 = var.VPC_ID
  name                   = "loki-${var.ORG_NAME}-ecs"
  description            = "Security group for Loki ECS container"
  revoke_rules_on_delete = true
}

resource "aws_security_group_rule" "https_ingress" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "TCP"
  description              = "Allow HTTPS inbound traffic from ALB"
  security_group_id        = aws_security_group.loki.id
  source_security_group_id = var.SOURCE_ALB_SECURITY_GROUP_ID
}

# Ingress rule to allow health checks from the ALB
# If your target group is configured to perform health checks on port 3100 using HTTP, the following conditions must be met:
# The security group of the Loki ECS container must have an ingress rule allowing traffic from the ALB security group on port 3100.
resource "aws_security_group_rule" "health_check_ingress" {
  type                     = "ingress"
  from_port                = 3100
  to_port                  = 3100
  protocol                 = "tcp"
  description              = "Allow health checks from ALB"
  security_group_id        = aws_security_group.loki.id
  source_security_group_id = var.SOURCE_ALB_SECURITY_GROUP_ID
}

# Ingress rule to allow traffic from the log-shipper λ function
resource "aws_security_group_rule" "lambda_ingress" {
  type                     = "ingress"
  from_port                = 3100
  to_port                  = 3100
  protocol                 = "tcp"
  description              = "Allow traffic from the log-shipper Lambda function"
  security_group_id        = aws_security_group.loki.id
  source_security_group_id = aws_security_group.log_shipper.id
}

# Ingress rule to allow traffic from the Grafana ECS container
resource "aws_security_group_rule" "grafana_ingress" {
  type                     = "ingress"
  from_port                = 3100
  to_port                  = 3100
  protocol                 = "tcp"
  description              = "Allow traffic from the Grafana ECS container"
  security_group_id        = aws_security_group.loki.id
  source_security_group_id = module.ecs_service_grafana.ecs_security_group_id
}

# By placing the λ function inside a VPC and attaching it to a security group, you gain the ability to restrict access to your Loki ECS container to only that λ function. This provides an additional layer of security, as your Loki ECS container will only accept traffic from specific, trusted sources.
# Controlled Access: By using security groups, you can tightly control which resources are allowed to communicate with your Loki ECS container, reducing the risk of unauthorized access.
# Enhanced Security: Restricting ingress to the Loki ECS container from only the λ function’s security group is a best practice in secure cloud architecture, especially when handling sensitive data like logs.

# Egress rule to allow all outbound traffic
resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.loki.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# By specifying the source security group IDs for the λ function (aws_security_group.lambda_sg.id) and the Grafana ECS container (module.ecs_service_grafana.ecs_security_group_id), you are explicitly restricting access to Loki on port 3100 to these two trusted sources only.
# No other resources, even if they are within the same VPC, will be able to communicate with Loki on port 3100 unless they are associated with one of these two security groups.
# No Public Access to Port 3100:
# Since there is no ingress rule allowing access from 0.0.0.0/0 or any other CIDR block on port 3100, external traffic cannot reach Loki on this port.
# Port 443 Ingress Rule: Keeping the ALB rule on port 443 is necessary for HTTPS access to Loki from external sources. However, this does not compromise the internal restriction on port 3100.
# Outbound Traffic: The egress rule allowing all outbound traffic (0.0.0.0/0) is standard and generally needed for ECS services to communicate with the internet, but it does not affect the inbound restrictions you have in place.
