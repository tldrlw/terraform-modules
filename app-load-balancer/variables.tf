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

variable "elb_account_id" {
  type    = string
  default = "127311923021"
  # setting the default to use1 so terraform doesn't ask for it if `enable_logs_to_s3_new_regions` is set to true
  # if `enable_logs_to_s3_new_regions` is set to false, then this value must be set to whatever the region is, unless it's use1
  description = "goes in bucket policy for alb_logs - https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html - check under 'Regions available before August 2022' for value"
}

variable "enable_logs_to_s3_new_regions" {
  type        = bool
  default     = false
  description = "bucket policy for alb_logs will differ for regions available after august 2022 - https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html#attach-bucket-policy - check and see if your region falls under this list, if so, set this to true"
}
