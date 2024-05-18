module "vpc" {
  source = "../boex_terraform_modules/services/vpc"
  tags   = var.tags
  vpc = {
    name       = "boex test"
    cidr       = "10.24.0.0/16"
    dual_stack = false
    igw        = "boex-igw"
    egw        = "boex-egw"
    single_ngw = true
  }
  subnets = {
    "pub" = {
      ipv4_cidr         = "10.24.1.0/24"
      public_subnet     = true
      availability_zone = "us-west-2a"
    },
    "priv" = {
      ipv4_cidr         = "10.24.2.0/24"
      public_subnet     = false
      availability_zone = "us-west-2b"
    },
    "priv2" = {
      ipv4_cidr         = "10.24.3.0/24"
      public_subnet     = false
      availability_zone = "us-west-2c"
    },
    "priv3" = {
      ipv4_cidr         = "10.24.4.0/24"
      public_subnet     = false
      availability_zone = "us-west-2d"
    }
  }
  lbs = {
    "pub-lb" = {
      internal = false
      type     = "network"
      subnets  = ["priv", "priv2"]
    }
  }
}

module "sg" {
  source = "../boex_terraform_modules/services/security_groups"

  vpc = {
    id   = module.vpc.vpc_id
    cidr = module.vpc.vpc_cidr
  }
  environment = "ops"
  tags        = var.tags
}

module "ec2_instances" {
  depends_on = [module.vpc]
  source = "../boex_terraform_modules/services/ec2"
  # vpc_id = module.vpc.vpc_id
  # igw_id = module.vpc.internet_gateway_id
  # prefix = var.prefix
  tags = var.tags

  ec2-instance = {
    "rancher" : {
      description        = ""
      security_group_ids = [module.sg.eks_sg_id]
      subnet_id          = module.vpc.subnets["pub"]
      static_ip          = ""
      instance_size      = "t3.medium"
      prefix             = "pub"
      volume_size = "40"
    },
    "bastion" : {
      description        = ""
      security_group_ids = [module.sg.bastion_sg_id]
      subnet_id          = module.vpc.subnets["pub"]
      static_ip          = ""
      instance_size      = "t3.micro"
      prefix             = "pub"
      volume_size = "16"
    },
    "test" : {
      description        = ""
      security_group_ids = [module.sg.bastion_sg_id]
      subnet_id          = module.vpc.subnets["pub"]
      static_ip          = ""
      instance_size      = ""
      prefix             = "pub"
      volume_size = "16"
    },
  }
  ssh_keys = []
}

output "node_public_ip" {
  value = module.ec2_instances.node_public_ip
}
output "node_internal_ip" {
  value = module.ec2_instances.node_internal_ip
}

module "rancher-server" {

  source = "../boex_terraform_modules/services/rancher"

  tags   = var.tags

  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
  ssh_private_key_pem = module.ec2_instances.ssh_private_key_pem
  subnet_id = module.vpc.subnets["pub"]
  vpc_id = module.vpc.vpc_id
  security_group_id = module.sg.eks_sg_id
  node_username = module.ec2_instances.node_username
  node_public_ip = module.ec2_instances.node_public_ip
  node_internal_ip = module.ec2_instances.node_internal_ip
  admin_password = var.admin_password
  rancher_server_dns = join(".", ["rancher", module.ec2_instances.rancher_server_url, "sslip.io"])
  workload_cluster_name = "cluster-k8s"
  rancher_kubernetes_version = "v1.28.8+k3s1"
  workload_kubernetes_version = "v1.28.8+rke2r1"
}