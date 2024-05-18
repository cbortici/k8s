# VPC variables
variable "tags" {
  type = map(any)
  default = {
    Owner : "boex-devops"
    purpose : "testing"
  }
}
# variable "vpc" {}
# variable "subnets" {}
# variable "lbs" {}

# SG variables
variable "security_groups" { default = {} }

# EC2 variables
variable "ec-2instance" { default = {} }
variable "ssh_keys" { default = [] }

variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "aws_region" {
    default = "us-west-2"  
}
variable "admin_password" {
  default = "123456789012"
}
# variable "prefix" {
#   type        = string
#   description = "Prefix added to names of all resources"
#   default = "bootstrap"
# }