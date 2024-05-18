# resource "aws_security_group" "security_group" {
#   for_each = var.security_groups

#   name        = each.key
#   vpc_id      = each.value.vpc_id
#   description = each.value.description

#   tags = var.tags
# }


# resource "aws_vpc_security_group_ingress_rule" "sg_ingress" {
#   for_each = { for key, value in local.sg_ingress : "${key}" => value }

#   security_group_id = aws_security_group.security_group[each.value.sg_id].id

#   cidr_ipv4   = each.value.cidr_ipv4
#   from_port   = each.value.from_port
#   to_port     = each.value.to_port
#   ip_protocol = each.value.protocol

# }


#### Example

# security_groups = {
#   test = {
#     vpc_id      = module.vpc.vpc_id
#     description = ""
#     ingress = [{
#       cidr_ipv4 = "10.24.0.0/16"
#       cidr_ipv6 = ""
#       to_port   = -1
#       from_port = -1
#       protocol  = "icmp"
#       },
#       {
#         cidr_ipv4 = "10.24.0.0/16"
#         cidr_ipv6 = ""
#         to_port   = 22
#         from_port = 22
#         protocol  = "tcp"
#     }]
#     egress = []
#   }
# }
