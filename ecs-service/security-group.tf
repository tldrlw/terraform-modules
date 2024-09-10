# ECS
resource "aws_security_group" "self" {
  vpc_id                 = var.vpc_id
  name                   = "${var.app_name}-ecs"
  revoke_rules_on_delete = true
}

resource "aws_security_group_rule" "https_ingress" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "TCP"
  description              = "Allow HTTPS inbound traffic from ALB"
  security_group_id        = aws_security_group.self.id
  source_security_group_id = var.source_security_group_id
}

# rule below is not in gc-res infra, but that ECS task is running fine (this wasn't, task was running, but target group health checks were failing, and task kept getting deregistered from it), not sure why I had to add another sg rule for here but not in gc-res infra...
# cgpt suggestion:
# Security Group Configuration: The security group for your ECS service (aws_security_group.ecs_sg) allows inbound traffic on port 80 and 443 from the ALB’s security group. However, since your application is running on port 3000, you should modify the security group rules to allow inbound traffic on port 3000 from the ALB security group.
resource "aws_security_group_rule" "container_ingress" {
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "TCP"
  description              = "Allow inbound traffic from ALB on port 3000"
  security_group_id        = aws_security_group.self.id
  source_security_group_id = var.source_security_group_id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow outbound traffic from ECS to internet/specific IPs"
  security_group_id = aws_security_group.self.id
  cidr_blocks       = var.security_group_egress_cidrs
}
