resource "aws_lb" "self" {
  name                       = var.alb_name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.self.id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = false
  # Enable access logging
  dynamic "access_logs" {
    for_each = var.enable_logs_to_s3 && length(aws_s3_bucket.alb_logs) > 0 ? [1] : []
    content {
      bucket  = aws_s3_bucket.alb_logs[0].bucket # Reference the first S3 bucket
      enabled = true
      # prefix  = "alb-logs" # Optional: Specify a prefix for the log files
    }
  }
}

resource "aws_lb_listener" "http_redirect_to_https" {
  load_balancer_arn = aws_lb.self.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  # default_action defines what the listener should do with the traffic that doesn’t match any specific rules. The common action is to forward traffic to a target group (see listener https), but you can also perform other actions like redirecting or returning a fixed response
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.self.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.self.arn
  }
  # in this example, the default_action will be taken when we hit yourhostname.com, since the listener rule below has the host_header condition set to the root domain
}

resource "aws_lb_listener_rule" "https" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.self.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
  condition {
    host_header {
      values = [var.hostname]
    }
  }
}

resource "aws_lb_target_group" "self" {
  name = "${var.target_group_name}-tg"
  # port        = 80
  # ^ use for nginx:latest
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Change target type to 'ip'
  health_check {
    path                = var.target_group_health_check
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Client: Sends a request.
# ALB: Receives the request.
# Listener: Listens on specified ports and routes traffic based on rules.
# Listener Rules: Define conditions for routing to target groups.
# Target Group: Receives traffic and forwards it to ECS tasks.
# ECS Tasks: Handle the request and return a response.

# you can configure an AWS Application Load Balancer (ALB) listener to route traffic to different target groups based on specific conditions, such as path patterns, host headers, HTTP methods, or even query string parameters. This is commonly done by setting up listener rules within the aws_lb_listener_rule resource, rather than directly within the aws_lb_listener resource

# Basic Listener Setup: Use aws_lb_listener to define the listener with a default action.
# Conditional Routing: Use aws_lb_listener_rule to define rules that route traffic to different target groups based on conditions like path patterns or host headers.
# Multiple Target Groups: You can route traffic to different target groups depending on the rules specified.
