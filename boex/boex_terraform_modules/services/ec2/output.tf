output "node_public_ip" {
  value = aws_instance.ec2["rancher"].public_ip
}
output "node_internal_ip" {
  value = aws_instance.ec2["rancher"].private_ip
}
output "node_username" {
  value = "ec2-user"
}
output "rancher_server_url" {
  value = aws_instance.ec2["rancher"].public_ip
}
output "ssh_private_key_pem" {
  value = tls_private_key.global_key.private_key_pem
}