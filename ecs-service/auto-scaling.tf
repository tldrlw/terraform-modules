# Define the auto-scaling target for the ECS service
resource "aws_appautoscaling_target" "example" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ECS_CLUSTER_NAME}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.AUTO_SCALING_MIN # Minimum number of tasks
  max_capacity       = var.AUTO_SCALING_MAX # Maximum number of tasks
  # Minimum and Maximum Constraints:
  # The auto-scaling system ensures that the desired count of tasks always stays within the range of min_capacity (1) and max_capacity (5).
  # For example, if there are already 4 tasks and scaling out by 3 tasks is triggered, only 1 task will be added to reach the maximum of 5.
  # High Load:
  # If the CPU utilization exceeds the highest defined range (>85%), the system will add 3 tasks, but only up to the max_capacity of 5.
  # Low Load:
  # If the CPU utilization drops below the lowest defined range (<15%), the system will remove 2 tasks, but not below the min_capacity of 1.
  tags = {
    Name = "${var.APP_NAME}-autoscaling-target"
  }
}

# CloudWatch alarm for high CPU utilization (Scale Out)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.APP_NAME}-high-cpu"
  comparison_operator = "GreaterThanThreshold" # Trigger when CPU is above the threshold
  evaluation_periods  = 2                      # Number of consecutive periods for evaluation
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60        # Check every 60 seconds
  statistic           = "Average" # Use the average CPU utilization
  threshold           = 75        # Trigger if CPU > 75%
  dimensions = {
    ClusterName = var.ECS_CLUSTER_NAME
    ServiceName = aws_ecs_service.app.name
  }
  alarm_actions = [aws_appautoscaling_policy.scale_out.arn] # Action triggers the scale-out policy
}

# CloudWatch alarm for low CPU utilization (Scale In)
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.APP_NAME}-low-cpu"
  comparison_operator = "LessThanThreshold" # Trigger when CPU is below the threshold
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 25 # Trigger if CPU < 25%
  dimensions = {
    ClusterName = var.ECS_CLUSTER_NAME
    ServiceName = aws_ecs_service.app.name
  }
  alarm_actions = [aws_appautoscaling_policy.scale_in.arn] # Action triggers the scale-in policy
}

# Step scaling policy for scaling out (adding tasks)
resource "aws_appautoscaling_policy" "scale_out" {
  name               = "${var.APP_NAME}-scale-out"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.example.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  policy_type        = "StepScaling"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity" # Adjust capacity by a fixed number of tasks
    cooldown                = 60                 # Wait time after scaling before another adjustment, cooldown ensures no rapid consecutive scaling actions.
    metric_aggregation_type = "Average"          # Aggregates metrics across all tasks (e.g., average CPU utilization).
    # The scaling logic starts evaluating when the metric (CPUUtilization) exceeds the alarm threshold (e.g., 75% in this case).
    # Scale-out step 1: If CPU utilization is 0–10% above the threshold (e.g., 75%–85% CPU): Add 2 tasks.
    step_adjustment {
      metric_interval_lower_bound = 0  # Lower bound: 0% above the threshold.
      metric_interval_upper_bound = 10 # Upper bound: 10% above the threshold.
      scaling_adjustment          = 2  # Add 2 tasks
    }
    # Scale-out step 2: If CPU utilization is greater than 10% above the threshold
    # Add 3 tasks if CPU > 85%
    step_adjustment {
      metric_interval_lower_bound = 10 # Lower bound: 10% above the threshold.
      # No upper bound here, so it handles all values greater than 10%.
      scaling_adjustment = 3 # Add 3 tasks
    }
  }
}

# Step scaling policy for scaling in (removing tasks)
resource "aws_appautoscaling_policy" "scale_in" {
  name               = "${var.APP_NAME}-scale-in"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.example.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  policy_type        = "StepScaling"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"
    # Scale-in step 1: If CPU utilization is between 0% and 10% below the threshold (threshold = 25%)
    # Remove 1 task if CPU is between 25% and 15%
    step_adjustment {
      metric_interval_lower_bound = -10 # Lower bound: 10% below the threshold.
      metric_interval_upper_bound = 0   # Upper bound: At the threshold.
      scaling_adjustment          = -1  # Remove 1 task
    }
    # Scale-in step 2: If CPU utilization is greater than 10% below the threshold
    # Remove 2 tasks if CPU < 15%
    step_adjustment {
      metric_interval_upper_bound = -10 # Upper bound: 10% below the threshold.
      # No lower bound here, so it handles all values less than 10% below the threshold.
      scaling_adjustment = -2 # Remove 2 tasks
    }
  }
}
