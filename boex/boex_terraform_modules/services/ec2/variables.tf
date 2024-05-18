variable "ec2-instance" {
  type = map(object({
    description        = string
    security_group_ids = list(string)
    subnet_id          = string
    static_ip          = string
    instance_size      = string
    prefix             = string
    volume_size        = number
  }))
}

variable "ssh_keys" {
  type        = list(string)
  description = "SSH keys list"
}

variable "tags" {
  type        = map(any)
  description = "Resource's tags"
}

# variable "prefix" {
#   type = string
# }
# locals {
#   node_username = "ec2-user"
# }
# variable "vpc_id" {
#   type = string
# }
# variable "igw_id" {
#   type = string
# }