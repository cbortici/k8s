variable "tags" {
  type        = map(any)
  description = "Resource's tags"
}

# variable "security_groups" {
#   description = "Security groups definition"
#   type = map(object({
#     vpc_id      = string
#     description = string
#     ingress = list(object({
#       cidr_ipv4 = string
#       cidr_ipv6 = string
#       to_port   = any
#       from_port = any
#       protocol  = string
#     }))
#     egress = list(object({
#       cidr_ipv4 = string
#       cidr_ipv6 = string
#       to_port   = any
#       from_port = any
#       protocol  = string
#     }))
#   }))
# }

variable "environment" {
  description = "App's environment"
  type        = string
}

variable "vpc" {
  description = "VPC ID"
  type        = map(string)
  nullable    = false
}


