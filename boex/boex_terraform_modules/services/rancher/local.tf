# Local resources

# Save kubeconfig file for interacting with the RKE cluster on your local machine
resource "local_file" "kube_config_server_yaml" {
  filename = format("%s/%s", path.root, "kube_config_server.yaml")
  content  = ssh_resource.retrieve_config.result
}

resource "local_file" "kube_config_workload_yaml" {
  depends_on = [rancher2_cluster_v2.cluster-k8s]
  filename = format("%s/%s", path.root, "kube_config_workload.yaml")
  content  = rancher2_cluster_v2.cluster-k8s.kube_config
}
