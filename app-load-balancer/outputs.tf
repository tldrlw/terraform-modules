output "alb_target_group_arn" {
  value = aws_lb_target_group.self.arn
}

output "alb_dns_name" {
  value = aws_lb.self.dns_name
}

output "alb_zone_id" {
  value = aws_lb.self.zone_id
}

output "alb_security_group_id" {
  value = aws_security_group.self.id
}
