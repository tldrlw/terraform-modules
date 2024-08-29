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

variable "subnets" {
  description = "List of subnet IDs to associate with the ECS service."
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs to associate with the ECS service."
  type        = list(string)
}

variable "container_port" {
  type = number
}

variable "host_port" {
  type = number
}
