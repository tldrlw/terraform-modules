variable "LOG_GROUP" {
  type = object({
    log_group     = string
    friendly_name = string
    arn           = string
  })
}

variable "LAMBDA_FUNCTION_NAME" {
  type = string
}

variable "LAMBDA_FUNCTION_ARN" {
  type = string
}

variable "ORG_NAME" {
  type = string
}
