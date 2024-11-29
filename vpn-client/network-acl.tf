# # Create a separate Network ACL (NACL) for the VPN subnet
# resource "aws_network_acl" "vpn_nacl" {
#   vpc_id = var.VPC_ID
#   tags = {
#     Name = "VPN Subnet NACL"
#   }
# }

# # Ingress Rule: Allow traffic from the VPN clients (using CLIENT_CIDR)
# resource "aws_network_acl_rule" "allow_vpn_inbound" {
#   network_acl_id = aws_network_acl.vpn_nacl.id
#   rule_number    = 100
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = var.CLIENT_CIDR # CIDR block for your VPN clients
#   from_port      = 443
#   to_port        = 443
#   egress         = false
# }

# # Ingress Rule: Allow traffic from the VPC (for internal communication)
# resource "aws_network_acl_rule" "allow_vpc_inbound" {
#   network_acl_id = aws_network_acl.vpn_nacl.id
#   rule_number    = 200
#   protocol       = "-1" # All protocols
#   rule_action    = "allow"
#   cidr_block     = var.VPC_CIDR # Your VPC CIDR
#   from_port      = 0
#   to_port        = 65535
#   egress         = false
# }

# # Egress Rule: Allow all outbound traffic from the VPN subnet (if required)
# resource "aws_network_acl_rule" "allow_vpn_outbound" {
#   network_acl_id = aws_network_acl.vpn_nacl.id
#   rule_number    = 100
#   protocol       = "-1" # All protocols
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0" # Allow all outbound traffic
#   from_port      = 0
#   to_port        = 65535
#   egress         = true
# }

# # Deny all other traffic to the VPN subnet (optional, for tighter security)
# resource "aws_network_acl_rule" "deny_other_vpn_traffic" {
#   network_acl_id = aws_network_acl.vpn_nacl.id
#   rule_number    = 500
#   protocol       = "-1" # All protocols
#   rule_action    = "deny"
#   cidr_block     = "0.0.0.0/0" # Deny all other traffic
#   from_port      = 0
#   to_port        = 65535
#   egress         = false
# }

# # Associate the VPN subnet with the new NACL
# resource "aws_network_acl_association" "vpn_subnet_association" {
#   network_acl_id = aws_network_acl.vpn_nacl.id
#   subnet_id      = aws_subnet.private.id # VPN subnet ID
# }
