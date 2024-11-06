variable "ALB_TARGET_GROUP_ARN_GRAFANA" {
  type = string
}

variable "ALB_TARGET_GROUP_ARN_LOKI" {
  type = string
}

variable "ECR_REPO_URL_GRAFANA" {
  type = string
}

variable "ECR_REPO_URL_LOKI" {
  type = string
}

variable "ECS_CLUSTER_ID" {
  type = string
}

variable "ECS_TASK_COUNT_GRAFANA" {
  type    = number
  default = 1
}

variable "ECS_TASK_COUNT_LOKI" {
  type    = number
  default = 1
}

variable "IMAGE_TAG_GRAFANA" {
  type    = string
  default = "latest"
}

variable "IMAGE_TAG_LOKI" {
  type    = string
  default = "latest"
}

variable "LINUX_ARM_64" {
  description = "set to true if building and pushing images to ECR on M-series Macs, personal use case: since building and pushing (locally) custom grafana and loki images (see blog-tldrlw repo > infrastructure/grafana-loki/docker-push-grafana.sh and infrastructure/grafana-loki/docker-push-loki.sh)"
  type        = bool
  default     = false
}

variable "LOG_GROUPS" {
  type = list(object({
    log_group     = string
    friendly_name = string
    arn           = string
  }))
}

variable "LOKI_URL" {
  type = string
}

variable "ORG_NAME" {
  type = string
}

variable "PASSWORD_GRAFANA" {
  type = string
}

variable "PRIVATE_SUBNETS" {
  description = "List of subnet IDs to associate with the log-shipper λ function."
  type        = list(string)
}

variable "PUBLIC_SUBNETS" {
  description = "List of subnet IDs to associate with the grafana and loki ECS services."
  type        = list(string)
}

variable "SOURCE_ALB_SECURITY_GROUP_ID" {
  type = string
}

variable "TEST_ENV_VAR_GRAFANA" {
  description = "change this value around to trigger creation of new task(s)"
  type        = string
  default     = "test"
}

variable "TEST_ENV_VAR_LOKI" {
  description = "change this value around to trigger creation of new task(s)"
  type        = string
  default     = "test"
}

variable "USERNAME_GRAFANA" {
  type = string
}

variable "VPC_ID" {
  type = string
}
