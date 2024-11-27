variable "PRIVATE_APIG_RESOURCES" {
  description = "List of API Gateway resource path parts to create"
  type        = list(string)
}

variable "PRIVATE_APIG_STAGE_NAME" {
  type = string
}

variable "APP_NAME" {
  type = string
}

variable "ECS_SERVICE_SECURITY_GROUP_ID" {
  type = string
}

variable "PUBLIC_SUBNET_IDS" {
  type = list(string)
}

variable "REGION" {
  type = string
}

variable "VPC_ID" {
  type = string
}

variable "PRIVATE_APIG_METHODS_AND_URIS" {
  type = map(object({
    method_id = string
    uri       = string
  }))
}
