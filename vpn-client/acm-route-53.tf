resource "aws_acm_certificate" "server_cert" {
  domain_name       = "vpn.${var.DOMAIN}" # Replace with your desired domain
  validation_method = "DNS"
  tags = {
    Name = "Client VPN Server Certificate"
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.server_cert.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
  zone_id = var.ROUTE_53_ZONE_ID
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "server_cert_validation" {
  certificate_arn         = aws_acm_certificate.server_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

resource "aws_route53_record" "vpn_dns" {
  zone_id = var.ROUTE_53_ZONE_ID
  name    = "vpn.${var.DOMAIN}"
  type    = "CNAME"
  records = [aws_ec2_client_vpn_endpoint.main.dns_name]
  ttl     = 300
}
