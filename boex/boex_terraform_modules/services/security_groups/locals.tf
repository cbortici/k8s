locals {
  # sg_ingress = flatten([for key, value in var.security_groups : [
  #   for ing in value.ingress :
  #   merge(ing, { sg_id = "${key}" })
  # ]])

  network = {
    ops = {
      public_subnet  = ["10.24.1.0/24"]
      private_subnet = ["10.24.2.0/24", "10.24.3.0/24", "10.24.4.0/24"]
    }
    dev = {
      public_subnet  = ["10.24.1.0/24"]
      private_subnet = ["10.24.2.0/24"]
    }
    test = {
      public_subnet  = ["10.24.1.0/24"]
      private_subnet = ["10.24.2.0/24"]
    }
    prod = {
      public_subnet  = ["10.24.1.0/24"]
      private_subnet = ["10.24.2.0/24"]
    }
  }

  devops_ips = ["0.0.0.0/0"]
}
