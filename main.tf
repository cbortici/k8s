# variable "key" {
#   type = string
# }
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.43.0"
    }
  }
  backend "s3" {
  }
}

provider "aws" {
  # Configuration options
  region = ""
  access_key = ""
  secret_key = ""
}
provider "kubernetes" {
    host                   = aws_eks_cluster.example.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.example.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.name]
      command     = "aws"
    }
  
}
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.example.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.example.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.name]
      command     = "aws"
    }
  }
}
data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = helm_release.nginx-ingress-controller.metadata[0].namespace
  }
  depends_on = [helm_release.nginx-ingress-controller]
}
output "ingress_hostname" {
  value = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
}
resource "helm_release" "nginx-ingress-controller" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace = "ingress"
  create_namespace = true

  # set {
  #   name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
  #   value = "external"
  # }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
    value = "ip"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

}
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace = "argocd"
  create_namespace = true

   values = [
    "${file("values.yaml")}"
  ]
  # set {
  #   name  = "create namespace"
  #   value = "true"
  # }

}
resource "aws_eks_cluster" "example" {
  name     = var.name
  role_arn = aws_iam_role.example.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private.id,
      aws_subnet.private1.id,
      aws_subnet.public.id,
      aws_subnet.public1.id
    ]

  }
      tags = {
    Name = "Main"
  }
}

output "endpoint" {
  value = aws_eks_cluster.example.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.example.certificate_authority[0].data
}
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "example"
  node_role_arn   = aws_iam_role.noderole.arn
  subnet_ids      = [
    aws_subnet.private.id,
    aws_subnet.private1.id
  ]
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = {
    Name = "Main"
  }
}