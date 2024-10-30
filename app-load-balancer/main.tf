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
  # Handles only the redirection from HTTP to HTTPS (no need to forward traffic to a target group).
  # default_action defines what the listener should do with the traffic that doesn’t match any specific rules. The common action is to forward traffic to a target group (see listener https ***not doing this anymore***), but you can also perform other actions like redirecting or returning a fixed response
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.self.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  # Instead of using a specific target group in the default action, you can rely solely on listener rules to forward traffic to the correct target group based on the conditions (e.g., host headers or paths).
  # Change the default_action in the aws_lb_listener for HTTPS (port 443) to a simple rule with no specific target group. All the traffic routing will be handled by the individual listener rules.
  default_action {
    # type             = "forward"
    # target_group_arn = aws_lb_target_group.self.arn
    type = "fixed-response" # If no rule matches, you can return a fixed response
    fixed_response {
      content_type = "text/plain"
      message_body = "No matching rule found"
      status_code  = "404"
    }
  }
}
# Will handle the routing of traffic to the correct target group via listener rules based on the host header (domain) or other conditions.

resource "aws_lb_listener_rule" "https" {
  count        = length(var.target_group_and_listener_config) # Create listener rules based on the number of target groups
  listener_arn = aws_lb_listener.https.arn
  priority     = 100 + count.index # Ensure a unique priority by adding the index to a base value
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.self[count.index].arn # Forward traffic to the respective target group
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
  condition {
    host_header {
      values = [var.target_group_and_listener_config[count.index].domain] # Use domain from the variable
    }
  }
}
# These rules define the host headers (subdomains) and forward traffic to the appropriate target group based on the target_group_and_listener_config variable.

resource "aws_lb_target_group" "self" {
  count       = length(var.target_group_and_listener_config) # Create target groups based on the length of the list
  name        = "${var.target_group_and_listener_config[count.index].name}-tg"
  port        = var.target_group_and_listener_config[count.index].port  # Reference port from variable
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = var.target_group_and_listener_config[count.index].health_check_path # Use health check path from the variable
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
