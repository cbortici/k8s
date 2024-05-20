# Rancher resources

# Initialize Rancher server
resource "rancher2_bootstrap" "admin" {
  depends_on = [
    helm_release.rancher_server
  ]

  provider = rancher2.bootstrap

  password  = var.admin_password
  telemetry = true
}

resource "rancher2_cloud_credential" "aws_credential" {
  provider = rancher2.admin
  name = "aws-credential"
  amazonec2_credential_config {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    default_region = "us-west-2"
  }
}
resource "time_sleep" "wait_10_seconds" {
  depends_on = [rancher2_cloud_credential.aws_credential]

  create_duration = "10s"
}
# # Create AmazonEC2 machine config v2
resource "rancher2_machine_config_v2" "ec2_config" {
  depends_on = [time_sleep.wait_10_seconds]
  provider = rancher2.admin
  generate_name = "ec2-config"
  amazonec2_config {
    ami =  "ami-0cf2b4e024cdb6960"
    region = "us-west-2"
    security_group = ["int-eks-access"]
    subnet_id = var.subnet_id
    vpc_id = var.vpc_id
    zone = "a"
    root_size = "40"
  }
}

resource "rancher2_cluster_v2" "cluster-k8s" {
  depends_on = [rancher2_machine_config_v2.ec2_config]
  provider = rancher2.admin
  name = "cluster-k8s"
  kubernetes_version = var.workload_kubernetes_version
  enable_network_policy = false
  rke_config {
    # nodes in this pool have all roles 
    machine_pools {
      cloud_credential_secret_name = rancher2_cloud_credential.aws_credential.id
      name = "control-plane"
      control_plane_role = true
      etcd_role = true
      worker_role = false
      quantity = 1
      machine_config {
        kind = rancher2_machine_config_v2.ec2_config.kind
        name = rancher2_machine_config_v2.ec2_config.name
      }
    }
    machine_pools {
    name = "worker"
    machine_labels = {
      "nodepool" = "linux"
    }
    cloud_credential_secret_name = rancher2_cloud_credential.aws_credential.id
    control_plane_role = false
    etcd_role = false
    worker_role = true
    quantity = 2
    drain_before_delete = true
    machine_config {
      kind = rancher2_machine_config_v2.ec2_config.kind
      name = rancher2_machine_config_v2.ec2_config.name
      }
    }
  }
}

resource "rancher2_secret_v2" "ebs-secret" {
  provider = rancher2.admin
  depends_on = [rancher2_cluster_v2.cluster-k8s]
  cluster_id = rancher2_cluster_v2.cluster-k8s.cluster_v1_id
  name = "aws-secret"
  namespace = "kube-system"
  type = "opaque"
  data = {
      key_id = "${var.aws_access_key}"
      access_key = "${var.aws_secret_key}"
  }
}
# resource "rancher2_catalog_v2" "bitnami" {
#   provider = rancher2.admin
#   cluster_id = rancher2_cluster_v2.cluster-k8s.cluster_v1_id
#   name = "bitnami"
#   url = "https://repo.vmware.com/bitnami-files"
#   enabled = true
#   depends_on = [
#     rancher2_cluster_v2.cluster-k8s
#   ]
# }
# resource "rancher2_app_v2" "joomla" {
#   provider = rancher2.admin
#   cluster_id = rancher2_cluster_v2.cluster-k8s.cluster_v1_id
#   name = "joomla"
#   namespace = "joomla-system"
#   repo_name = rancher2_catalog_v2.bitnami.name
#   chart_name = "joomla"
#   depends_on = [
#     rancher2_catalog_v2.bitnami
#   ]
# }
# resource "rancher2_catalog_v2" "ebs" {
#   provider = rancher2.admin
#   depends_on = [rancher2_cluster_v2.cluster-k8s]
#   cluster_id = rancher2_cluster_v2.cluster-k8s.cluster_v1_id
#   name = "aws-ebs-csi-driver"
#   url = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
#   timeouts {
#     create = "2m"
#     delete = "2m"
#   }
# }
# resource "rancher2_app_v2" "ebs" {
#   provider = rancher2.admin
#   depends_on = [rancher2_catalog_v2.ebs]
#   cluster_id = rancher2_cluster_v2.cluster-k8s.cluster_v1_id
#   name = "aws-ebs-csi-driver"
#   namespace = "kube-system"
#   repo_name = "aws-ebs-csi-driver"
#   chart_name = "aws-ebs-csi-driver"
#   chart_version = "2.31.0"
# }
#Create a new Rancher2 App V2 using
# resource "rancher2_app_v2" "foo" {
#   depends_on = [rancher2_cluster_v2.cluster-k8s]
#   provider = rancher2.admin
#   cluster_id = rancher2_cluster_v2.cluster-k8s.cluster_v1_id
#   name = "longhorn"
#   namespace = "longhorn-system"
#   repo_name = "rancher-charts"
#   chart_name = "longhorn"
#   chart_version = "103.3.0+up1.6.1"
# }