locals {
  enis = {
    for key, value in var.ec2-instance : key => { "subnet_id" : value.subnet_id, "static_ip" : value.static_ip } if value.static_ip != ""
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

output "ami" {
  value = data.aws_ami.ubuntu
}

resource "aws_instance" "ec2" {
  for_each        = var.ec2-instance
  ami             = data.aws_ami.sles.id
  instance_type   = each.value.instance_size != "" ? each.value.instance_size : "t3.micro"
  subnet_id       = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  key_name        = aws_key_pair.key_pair.key_name
  root_block_device {
    volume_size   = each.value.volume_size
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]
  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = tls_private_key.global_key.private_key_pem
    }
  }
  user_data       = length(var.ssh_keys) < 1 ? null : <<-EOF
                    #!/bin/bash
                    for key in "${var.ssh_keys}"; do
                      echo "$key" > $HOME/.ssh/authorized_keys
                    done
                    EOF

  tags = merge(var.tags, { Name = format("%s-%s", "${each.value.prefix}", "${each.key}") })
}

resource "aws_network_interface" "ec2-nic" {
  for_each    = local.enis
  subnet_id   = each.value.subnet_id
  private_ips = [each.value.static_ip]
}

resource "aws_network_interface_attachment" "k8snode" {
  for_each = local.enis

  instance_id          = aws_instance.ec2[each.key].id
  network_interface_id = aws_network_interface.ec2-nic[each.key].id
  device_index         = 1
}
# # Data for AWS module

# # AWS data
# # ----------------------------------------------------------

# # Use latest SLES 15 SP3
data "aws_ami" "sles" {
  most_recent = true
  owners      = ["013907871322"] # SUSE

  filter {
    name   = "name"
    values = ["suse-sles-15-sp3*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# # AWS infrastructure resources

resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "ssh_private_key_pem" {
  filename        = "${path.module}/id_rsa"
  content         = tls_private_key.global_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "ssh_public_key_openssh" {
  filename = "${path.module}/id_rsa.pub"
  content  = tls_private_key.global_key.public_key_openssh
}

# Temporary key pair used for SSH accesss
resource "aws_key_pair" "key_pair" {
  key_name_prefix = "bootstrap-rancher-"
  public_key      = tls_private_key.global_key.public_key_openssh
}

# # resource "aws_route_table" "rancher_route_table" {
# #   vpc_id = var.vpc_id

# #   route {
# #     cidr_block = "0.0.0.0/0"
# #     gateway_id = var.igw_id
# #   }

# #   tags = {
# #     Name = "${var.prefix}-rancher-route-table"
# #   }
# # }

# # resource "aws_route_table_association" "rancher_route_table_association" {
# #   for_each = local.enis
# #   subnet_id      = each.value.subnet_id
# #   route_table_id = aws_route_table.rancher_route_table.id
# # }

# # Security group to allow all traffic
# resource "aws_security_group" "rancher_sg_allowall" {
#   name        = "${var.prefix}-rancher-allowall"
#   description = "Rancher ${var.prefix} - allow all traffic"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = "0"
#     to_port     = "0"
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = "0"
#     to_port     = "0"
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Creator = "rancher-${var.prefix}"
#   }
# }

# # AWS EC2 instance for creating a single node RKE cluster and installing the Rancher server
# resource "aws_instance" "rancher_server" {
#   for_each = local.enis
#   # depends_on = [
#   #   aws_route_table_association.rancher_route_table_association
#   # ]
#   ami           = data.aws_ami.sles.id
#   instance_type = "t3.medium"

#   key_name                    = aws_key_pair.key_pair.key_name
#   vpc_security_group_ids      = [aws_security_group.rancher_sg_allowall.id]
#   subnet_id                   = each.value.subnet_id
#   associate_public_ip_address = true

#   root_block_device {
#     volume_size = 40
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "echo 'Waiting for cloud-init to complete...'",
#       "cloud-init status --wait > /dev/null",
#       "echo 'Completed cloud-init!'",
#     ]

#     connection {
#       type        = "ssh"
#       host        = self.public_ip
#       user        = local.node_username
#       private_key = tls_private_key.global_key.private_key_pem
#     }
#   }

#   tags = {
#     Name    = "${var.prefix}-rancher-server"
#     Creator = "rancher-${var.prefix}"
#   }
# }

