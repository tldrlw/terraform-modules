variable "app_name" {
  type = string
}

variable "ecr_repo_url" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "task_count" {
  type = number
}

variable "alb_target_group_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "source_security_group_id" {
  type        = string
  description = "this will be the security group id of the ALB"
}

variable "subnets" {
  description = "List of subnet IDs to associate with the ECS service."
  type        = list(string)
}

variable "container_port" {
  type = number
}

variable "host_port" {
  type = number
}

variable "linux_arm64" {
  type    = bool
  default = false
}

variable "security_group_egress_cidrs" {
  type        = list(string)
  description = "set to ['0.0.0.0/0'] if you want it to be open to the world, or else, e.g., '[your.office.ip/32', 'your.other.ip/32'], etc."
}

variable "cpu" {
  type    = string
  default = "256"
}

variable "memory" {
  type    = string
  default = "512"
}
# ^ allowed cpu and memory combinations: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
# ^ defaults are the lowest allowed values
