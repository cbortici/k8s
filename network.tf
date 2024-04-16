resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
    tags = {
      Name = "main"
    }  
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "nat"
  }
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "nat"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private"
  }
}
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id
  depends_on                = [aws_route_table.private]
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public"
  }
}
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id
  depends_on                = [aws_route_table.public]
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}


# resource "aws_route_table_association" "public-us-east-1a" {
#   subnet_id      = aws_subnet.example[0].id
#   route_table_id = aws_route_table.public.id
# }
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/19"
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}
resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.32.0/19"
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.64.0/19"
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "3"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}
resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.96.0/19"
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "4"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}
resource "aws_route53_zone" "example" {
  name = "ttyargocd.com"
}
resource "aws_route53_record" "web" {
  zone_id = aws_route53_zone.example.zone_id
  name    = "test"
  type    = "CNAME"
  ttl     = 300
  records = [data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname]
}
# data "aws_availability_zones" "available" {
#   state = "available"
# }
# resource "aws_subnet" "example" {
#   count = 2

#   availability_zone = data.aws_availability_zones.available.names[count.index]
#   cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
#   vpc_id            = aws_vpc.main.id
#     tags = {
#     "kubernetes.io/cluster/${var.name}" = "shared"
#     "kubernetes.io/role/internal-elb"           = "1"
#     }  
# }

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "dev-IG"
  }
}

resource "aws_eip" "lb" {
  depends_on    = [aws_internet_gateway.gw]
  vpc           = true
}

# resource "aws_nat_gateway" "natgw" {
#   allocation_id = aws_eip.lb.id
#   subnet_id     = flatten([aws_subnet.example[*].id])
#   depends_on = [aws_internet_gateway.gw]
#   tags = {
#     Name = "gw NAT"
#   }
# }