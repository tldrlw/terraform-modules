variable "CLIENT_CIDR_BLOCK" {
  type        = string
  description = "Client CIDR block for the VPN endpoint"
  # default     = "10.1.0.0/22"
}

variable "ROUTE_53_ZONE_ID" {
  description = "Zone ID of the Route 53 hosted zone for certificate validation"
  type        = string
}

variable "VPC_CIDR" {
  type = string
}

variable "VPC_ID" {
  type = string
}
