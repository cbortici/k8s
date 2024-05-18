# Variables for rancher common module

# Required
variable "tags" {
  type        = map(any)
  description = "Resource's tags"
}

variable "node_public_ip" {
  type        = string
  description = "Public IP of compute node for Rancher cluster"
}

variable "node_internal_ip" {
  type        = string
  description = "Internal IP of compute node for Rancher cluster"
}

# Required
variable "node_username" {
  type        = string
  description = "Username used for SSH access to the Rancher server cluster node"
}

# Required
variable "ssh_private_key_pem" {
  type        = string
  description = "Private key used for SSH access to the Rancher server cluster node"
}

variable "rancher_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for Rancher server cluster"
}

variable "cert_manager_version" {
  type        = string
  description = "Version of cert-manager to install alongside Rancher (format: 0.0.0)"
  default     = "1.11.0"
}

variable "rancher_version" {
  type        = string
  description = "Rancher server version (format v0.0.0)"
  default     = "2.8.3"
}

# Required
variable "rancher_server_dns" {
  type        = string
  description = "DNS host name of the Rancher server"
}

# Required
variable "admin_password" {
  type        = string
  description = "Admin password to use for Rancher server bootstrap, min. 12 characters"
}

variable "workload_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for managed workload cluster"
}

# Required
variable "workload_cluster_name" {
  type        = string
  description = "Name for created custom workload cluster"
}

variable "rancher_helm_repository" {
  type        = string
  description = "The helm repository, where the Rancher helm chart is installed from"
  default     = "https://releases.rancher.com/server-charts/latest"
}
variable "aws_access_key" {
  type        = string
  description = "AWS access key used to create infrastructure"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key used to create AWS infrastructure"
}

variable "aws_session_token" {
  type        = string
  description = "AWS session token used to create AWS infrastructure"
  default     = ""
}

variable "vpc_id" {
  type = string
  description = "VPC id"
}
variable "subnet_id" {
  type = string
  description = "Subnet ID"
}
variable "security_group_id" {
  type = string
}