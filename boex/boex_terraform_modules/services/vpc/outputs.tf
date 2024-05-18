output "subnets" {
  description = "Subnets data"
  value       = { for key, value in aws_subnet.subnets : key => value.id }
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = aws_vpc.vpc.cidr_block
}
output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}
