variable "function_name" {
  type = string
}

variable "source_dir" {
  type = string
}
variable "handler_file_prefix" {
  type = string
}

variable "memory_size" {
  type    = string
  default = 128
}

variable "timeout" {
  type    = string
  default = 3
}

variable "environment_variables" {
  type = map(string)
  default = {
    FOO = "bar"
  }
}

variable "REST_method" {
  type = string
}

variable "is_s3" {
  type = bool
  # default = null
}

variable "s3_bucket_arn" {
  type    = string
  default = null
}

variable "s3_bucket_permissions" {
  type    = list(string)
  default = [""]
}

variable "is_dydb" {
  type = bool
  # default = null
}

variable "dydb_table_arn" {
  type    = string
  default = ""
}

variable "dydb_table_permissions" {
  type    = list(string)
  default = [""]
}

variable "function_url" {
  type    = bool
  default = true
}

# apig
variable "REST_api_id" {
  type = string
}

variable "REST_api_execution_arn" {
  type = string
}

variable "REST_api_resource_id" {
  type = string
}

variable "REST_api_authorizer_id" {
  type = string
}

variable "enable_cors" {
  type        = bool
  description = "Set this to true for, e.g., you have client components (as opposed to server-side components) in your next.js app making API calls to the lambda function"
  default     = false
}
