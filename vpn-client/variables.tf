variable "NAME" {
  type    = string
  default = "shared-tldrlw"
}

variable "CLIENT_CIDR" {
  type        = string
  description = "Client CIDR block for the VPN endpoint"
}

variable "DOMAIN" {
  type = string
}

variable "PRIVATE_SUBNET_CIDR" {
  type = string
}

variable "ROUTE_53_ZONE_ID" {
  description = "Zone ID of the Route 53 hosted zone for certificate validation"
  type        = string
}

variable "TRUSTED_CIDR" {
  type = string
}

variable "VPC_CIDR" {
  type = string
}

variable "VPC_ID" {
  type = string
}

variable "ORG" {
  type = string
}

variable "PROJECT" {
  type = string
}

variable "ENV" {
  type = string
}

variable "VPN_INACTIVE_PERIOD" {
  type = string
}
