output "alb_target_group_arns" {
  value = aws_lb_target_group.self[*].arn # Collects the ARNs of all target groups into a list
}
# aws_lb_target_group.self[*].arn: The [*] is a splat expression that collects all ARNs from the aws_lb_target_group.self resource, which will include all instances of the target groups created by the count meta-argument.
# Output: This will output a list of ARNs for all the dynamically created target groups.
# alb_target_group_arns = [
#   "arn:aws:elasticloadbalancing:region:account-id:targetgroup/app1/abc123",
#   "arn:aws:elasticloadbalancing:region:account-id:targetgroup/app2/def456",
#   "arn:aws:elasticloadbalancing:region:account-id:targetgroup/app3/ghi789"
# ]

output "alb_dns_name" {
  value = aws_lb.self.dns_name
}

output "alb_zone_id" {
  value = aws_lb.self.zone_id
}

output "alb_security_group_id" {
  value = aws_security_group.self.id
}
