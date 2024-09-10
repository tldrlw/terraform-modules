# ALB
resource "aws_security_group" "self" {
  vpc_id                 = var.vpc_id
  name                   = "${var.alb_name}-alb"
  description            = "Security group for alb"
  revoke_rules_on_delete = true
}

resource "aws_security_group_rule" "https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  description       = "Allow HTTPS inbound traffic from internet/specific IPs"
  security_group_id = aws_security_group.self.id
  cidr_blocks       = var.security_group_cidrs
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow outbound traffic from ALB"
  security_group_id = aws_security_group.self.id
  cidr_blocks       = var.security_group_cidrs
}
