# output "local" {
#   value = local.sg_ingress
# }

output "bastion_sg_id" {
  value = aws_security_group.ops_bastion_ssh[0].id
}

output "int_http_https_sg_id" {
  value = aws_security_group.internal_http_https[0].id
}

output "postgres_sg_id" {
  value = aws_security_group.int_postgres_access[0].id
}

output "mongo_sg_id" {
  value = aws_security_group.int_mongodb_access[0].id
}

output "ext_http_https_sg_id" {
  value = aws_security_group.external_http_https[0].id
}

output "eks_sg_id" {
  value = aws_security_group.eks[0].id
}
