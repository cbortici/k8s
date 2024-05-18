variable "tags" {
  type        = map(any)
  description = "Resource's tags"
}

variable "vpc" {
  description = "VPC Configuration"
  type = object({
    name       = string
    cidr       = string
    dual_stack = bool
    igw        = string
    egw        = string
    single_ngw = bool
  })
}

variable "subnets" {
  description = "Subnets Configuration"
  type = map(object({
    availability_zone = string
    public_subnet     = bool
    ipv4_cidr         = string
    # ipv6_cidr         = string
  }))
  default = {
    "default" = {
      availability_zone = ""
      public_subnet     = true
      ipv4_cidr         = ""
      # ipv6_cidr         = null
    }
  }
}

variable "lbs" {
  description = "Load balancers configuration"
  type = map(object({
    internal = bool
    type     = string
    # security_groups = list(string)
    subnets = list(string)
  }))
}
