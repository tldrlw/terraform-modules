variable "CLIENT_CIDR" {
  type        = string
  description = "Client CIDR block for the VPN endpoint"
}

variable "DOMAIN" {
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

