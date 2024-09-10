# ECS
resource "aws_security_group" "self" {
  vpc_id                 = var.vpc_id
  name                   = "${var.app_name}-ecs"
  revoke_rules_on_delete = true
}

# resource "aws_security_group_rule" "http_alb_ingress" {
#   type                     = "ingress"
#   from_port                = 80 # Restrict to the ports your ECS service uses
#   to_port                  = 80
#   protocol                 = "TCP"
#   description              = "Allow inbound traffic from ALB"
#   security_group_id        = aws_security_group.self.id
#   source_security_group_id = var.source_security_group_id
# }

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
  # cidr_blocks       = ["xx.xx.xx.xx/xx"] # Replace with specific IPs or ranges as needed
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
