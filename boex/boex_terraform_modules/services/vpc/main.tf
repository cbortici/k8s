locals {
  public_subnets  = [for key, val in var.subnets : key if val.public_subnet]
  private_subnets = [for key, val in var.subnets : key if !val.public_subnet]
  egw_ds          = [for key, val in var.subnets : key if var.vpc.dual_stack && !val.public_subnet]
  sigle_ngw       = ["boex"]
}

### Create VPC & Subnets

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc.cidr

  assign_generated_ipv6_cidr_block = var.vpc.dual_stack

  tags = merge(var.tags, { Name = "${var.vpc.name}" })
}


resource "aws_subnet" "subnets" {
  for_each = var.subnets
  vpc_id   = aws_vpc.vpc.id

  availability_zone = each.value.availability_zone
  cidr_block        = each.value.ipv4_cidr
  # ipv6_cidr_block                 = each.value.ipv6_cidr
  # ipv6_native                     = each.value.ipv6_only # IPv6 only network
  map_public_ip_on_launch         = each.value.public_subnet
  assign_ipv6_address_on_creation = (each.value.public_subnet && var.vpc.dual_stack)

  tags = merge(var.tags, { Name = "${each.key}" })

  depends_on = [aws_vpc.vpc]
}

### Grant public subnet access to internet

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, { Name = "${var.vpc.igw}" })
}


resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, { Name = "${var.vpc.name} - Public RT" })
}

### Add route for IPv6 
resource "aws_route" "ds_route" {
  count = var.vpc.dual_stack ? 1 : 0

  route_table_id              = aws_route_table.pub_rt.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "pub_rt_association" {
  for_each = toset(local.public_subnets)

  subnet_id      = aws_subnet.subnets[each.value].id
  route_table_id = aws_route_table.pub_rt.id
}

### Grant private subnet 

resource "aws_eip" "eip" {
  for_each = toset(var.vpc.single_ngw ? local.sigle_ngw : local.private_subnets)

  domain = "vpc"

  tags = merge(var.tags, { Name = "ngw-${each.value}" })
}

resource "aws_nat_gateway" "ngw" {
  for_each = toset(var.vpc.single_ngw ? local.sigle_ngw : local.private_subnets)

  allocation_id = aws_eip.eip[each.value].id
  subnet_id     = aws_subnet.subnets[local.public_subnets[0]].id

  tags = merge(var.tags, { Name = "ngw-${each.value}" })
}


resource "aws_egress_only_internet_gateway" "egw" {
  count = var.vpc.dual_stack ? 1 : 0

  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { Name = "${var.vpc.egw}" })
}

resource "aws_route_table" "priv_rt" {
  for_each = toset(local.private_subnets)
  vpc_id   = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"

    # "boex" is the value from local.single_ngw
    nat_gateway_id = var.vpc.single_ngw ? aws_nat_gateway.ngw["boex"].id : aws_nat_gateway.ngw[each.value].id
  }

  tags = merge(var.tags, { Name = "${var.vpc.name} - ${each.value} - RT" })
}

resource "aws_route" "ds_route_priv" {
  count = length(local.egw_ds)

  route_table_id              = aws_route_table.priv_rt[local.private_subnets[count.index]].id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.egw[0].id
}

resource "aws_route_table_association" "priv_rt_association" {
  for_each = toset(local.private_subnets)

  subnet_id      = aws_subnet.subnets[each.value].id
  route_table_id = aws_route_table.priv_rt[each.value].id
}

resource "aws_lb" "lbs" {
  for_each = var.lbs

  name     = each.key
  internal = each.value.internal
  # security_groups = each.value.security_groups # valid for ALB only
  subnets = [for sub in each.value.subnets : aws_subnet.subnets[sub].id]

  ip_address_type = var.vpc.dual_stack ? "dualstack" : "ipv4"

  tags = var.tags
}
