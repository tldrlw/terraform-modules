variable "APIG_SECURITY_GROUP_ID" {
  type = string
}

variable "DYDB_PERMISSIONS" {
  type = list(string)
}

variable "DYDB_TABLE_ARN" {
  type = string
}

variable "ENV_VARS" {
  type = map(string)
  default = {
    FOO = "bar"
  }
}

variable "HANDLER_FILE_PREFIX" {
  type = string
}

variable "HTTP_METHOD" {
  type = string
}

variable "MEMORY_SIZE" {
  type    = string
  default = 128
}

variable "NAME" {
  type = string
}

variable "PRIVATE_APIG_REST_API_EXECUTION_ARN" {
  type = string
}

variable "PRIVATE_APIG_REST_API_ID" {
  type = string
}

variable "PRIVATE_APIG_REST_API_RESOURCE_ID" {
  type = string
}

variable "PRIVATE_SUBNET_IDS" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "SOURCE_DIR" {
  type = string
}

variable "TIMEOUT" {
  type    = string
  default = 10
}

variable "VPC_ENDPOINT_DYDB_PREFIX_LIST_ID" {
  type = string
}

variable "VPC_ID" {
  type = string
}