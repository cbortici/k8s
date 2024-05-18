resource "aws_security_group" "ops_bastion_ssh" {
  count = contains(["ops", "dev", "test", "prod"], var.environment) ? 1 : 0

  name        = "ops-bastion-ssh"
  description = "Bastion ssh SG"
  vpc_id      = var.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.devops_ips
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.devops_ips
  }
  tags = var.tags
}

resource "aws_security_group" "internal_http_https" {
  count = contains(["ops", "dev", "test", "prod"], var.environment) ? 1 : 0

  name        = "int-http_https"
  description = "HTPP/S internal security group"
  vpc_id      = var.vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = concat(
      local.network[var.environment].public_subnet,
    local.network[var.environment].private_subnet)
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = concat(
      local.network[var.environment].public_subnet,
    local.network[var.environment].private_subnet)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr]
  }

  tags = var.tags
}

resource "aws_security_group" "external_http_https" {
  count = contains(["ops", "dev", "test", "prod"], var.environment) ? 1 : 0

  vpc_id      = var.vpc.id
  name        = "external-http-https"
  description = "HTTP/S external security group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "int_postgres_access" {
  count = contains(["ops", "dev", "test", "prod"], var.environment) ? 1 : 0

  vpc_id      = var.vpc.id
  name        = "int-postgres-access"
  description = "Internal PostgreSQL security group"

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = concat(
      local.network[var.environment].public_subnet,
    local.network[var.environment].public_subnet)
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = concat(
      local.network[var.environment].public_subnet,
    local.network[var.environment].public_subnet)
  }

  tags = var.tags
}

resource "aws_security_group" "int_mongodb_access" {
  count = contains(["ops", "dev", "test", "prod"], var.environment) ? 1 : 0

  vpc_id      = var.vpc.id
  name        = "int-mongodb-access"
  description = "Internal MongoDB security group"

  ingress {
    from_port = 27017
    to_port   = 27017
    protocol  = "tcp"
    cidr_blocks = concat(
      local.network[var.environment].public_subnet,
    local.network[var.environment].public_subnet)
  }

  egress {
    from_port = 27017
    to_port   = 27017
    protocol  = "tcp"
    cidr_blocks = concat(
      local.network[var.environment].public_subnet,
    local.network[var.environment].public_subnet)
  }

  tags = var.tags
}


# ports source
# https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/installation-requirements/port-requirements#ports-for-rancher-server-nodes-on-rke
resource "aws_security_group" "eks" {
  count = contains(["ops", "dev", "test", "prod"], var.environment) ? 1 : 0

  vpc_id      = var.vpc.id
  name        = "int-eks-access"
  description = "EKS security group"
  
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # rancher agents
  # ingress {
  #   from_port = 443
  #   to_port   = 443
  #   protocol  = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # ingress {
  #   from_port = 5473
  #   to_port   = 5473
  #   protocol  = "tcp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }
  # # cert manager liveness prod
  # ingress {
  #   from_port = 6080
  #   to_port   = 6080
  #   protocol  = "tcp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }

  # # etcd client requests
  # ingress {
  #   from_port = 2379
  #   to_port   = 2379
  #   protocol  = "tcp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }

  # # etcd peer communication
  # ingress {
  #   from_port = 2380
  #   to_port   = 2380
  #   protocol  = "tcp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }

  # # k8s api
  # ingress {
  #   from_port = 6443
  #   to_port   = 6443
  #   protocol  = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # # Nginx Ingress's Validating Webhook
  # ingress {
  #   from_port = 8443
  #   to_port   = 8443
  #   protocol  = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # #Canal/Flannel VXLAN overlay networking
  # ingress {
  #   from_port = 8472
  #   to_port   = 8472
  #   protocol  = "udp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }
  # ingress {
  #   from_port = 9090
  #   to_port   = 9090
  #   protocol  = "tcp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }
  # # Canal/Flannel liveness/readiness probe
  # ingress {
  #   from_port = 9099
  #   to_port   = 9099
  #   protocol  = "tcp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }

  # ingress {
  #   from_port = 9345
  #   to_port   = 9345
  #   protocol  = "tcp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }
  # # Metrics server communication with all nodes
  # ingress {
  #   from_port = 10250
  #   to_port   = 10255
  #   protocol  = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # # ssh provisioning of node by rke
  # ingress {
  #   from_port = 22
  #   to_port   = 22
  #   protocol  = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port = 80
  #   to_port   = 80
  #   protocol  = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port = 30000
  #   to_port   = 32767
  #   protocol  = "0"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }


  # egress {
  #   from_port = 22
  #   to_port   = 22
  #   protocol  = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  
  # egress {
  #   from_port = 80
  #   to_port   = 80
  #   protocol  = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # egress {
  #   from_port = 443
  #   to_port   = 443
  #   protocol  = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # egress {
  #   from_port = 2367
  #   to_port   = 2367
  #   protocol  = "tcp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }

  # egress {
  #   from_port = 5473
  #   to_port   = 5473
  #   protocol  = "tcp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }
  # # cert manager liveness prod
  # egress {
  #   from_port = 6080
  #   to_port   = 6080
  #   protocol  = "tcp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }

  # egress {
  #   from_port = 6443
  #   to_port   = 6443
  #   protocol  = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # egress {
  #   from_port = 9090
  #   to_port   = 9090
  #   protocol  = "tcp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }
  
  # egress {
  #   from_port = 9099
  #   to_port   = 9099
  #   protocol  = "tcp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }

  # egress {
  #   from_port = 9345
  #   to_port   = 9345
  #   protocol  = "tcp"
  #   cidr_blocks = concat(
  #     local.network[var.environment].public_subnet,
  #   local.network[var.environment].public_subnet)
  # }

  # egress {
  #   from_port = 10250
  #   to_port   = 10255
  #   protocol  = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # egress {
  #   from_port = 30000
  #   to_port   = 32767
  #   protocol  = "0"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  tags = var.tags
}
