variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "alb_name" {
  type = string
}

variable "hostname" {
  type = string
}

variable "target_group_name" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "security_group_cidrs" {
  type        = list(string)
  description = "set to ['0.0.0.0/0'] if you want it to be open to the world, or else, e.g., '[your.office.ip/32', 'your.other.ip/32'], etc."
}

variable "enable_logs_to_s3" {
  type    = bool
  default = false # Set this to true when you want to enable S3 logging
}
