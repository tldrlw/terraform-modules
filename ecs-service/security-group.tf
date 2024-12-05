# ECS
resource "aws_security_group" "self" {
  vpc_id                 = var.vpc_id
  name                   = "${var.APP_NAME}-ecs"
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

# cgpt suggestion:
# Security Group Configuration: The security group for your ECS service (aws_security_group.ecs_sg) allows 
# inbound traffic on port 80 and 443 from the ALB’s security group. However, since your application is running 
# on port 3000, you should modify the security group rules to allow inbound traffic on port 3000 from the 
# ALB security group.
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

# guide for SGs:
# https://medium.com/the-cloud-journal/ecs-fargate-with-alb-deployment-using-terraform-part-3-eb52309fdd8f

# commands for when terraform can't delete SGs:
# aws ec2 delete-security-group --group-id sg-032d87e97958ab62c --profile refayatabid --region ap-south-2
# aws ec2 describe-network-interfaces --filters Name=group-id,Values=sg-032d87e97958ab62c --query 'NetworkInterfaces[*].NetworkInterfaceId' --output text --profile refayatabid --region ap-south-2
# aws ec2 delete-network-interface --network-interface-id eni-0b64017b89f8304a3 --profile refayatabid --region ap-south-2
# aws ec2 describe-network-interfaces --network-interface-ids eni-0b64017b89f8304a3 --profile refayatabid --region ap-south-2
# aws ec2 detach-network-interface --attachment-id eni-attach-0e8f250bfa3b2b76d --profile refayatabid --region ap-south-2
# aws ec2 delete-network-interface --network-interface-id eni-0b64017b89f8304a3 --profile refayatabid --region ap-south-2
