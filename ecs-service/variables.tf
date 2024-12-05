variable "alb_target_group_arn" {
  type = string
}

variable "APP_NAME" {
  type = string
}

variable "AUTO_SCALING_MAX" {
  type    = number
  default = 5
}

variable "AUTO_SCALING_MIN" {
  type    = number
  default = 1
}

variable "container_port" {
  type = number
}

variable "cpu" {
  type    = string
  default = "256"
}

variable "ECS_CLUSTER_NAME" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "ecr_repo_url" {
  type = string
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "host_port" {
  type = number
}

variable "image_tag" {
  type = string
}

variable "linux_arm64" {
  type    = bool
  default = false
}

variable "memory" {
  type    = string
  default = "512"
}

variable "s3_access" {
  description = "if set to true, must provide bucket name set to `s3_bucket`"
  type        = bool
  default     = false
}

variable "s3_bucket" {
  type    = string
  default = ""
}

variable "security_group_egress_cidrs" {
  type        = list(string)
  description = "set to ['0.0.0.0/0'] if you want it to be open to the world, or else, e.g., '[your.office.ip/32', 'your.other.ip/32'], etc."
}

variable "source_security_group_id" {
  type        = string
  description = "this will be the security group id of the ALB"
}

variable "subnets" {
  description = "List of subnet IDs to associate with the ECS service."
  type        = list(string)
}

variable "vpc_id" {
  type = string
}
