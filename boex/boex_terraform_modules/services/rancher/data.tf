# Data for rancher common module

# Kubernetes data
# ----------------------------------------------------------

# # Rancher certificates
# data "kubernetes_secret" "rancher_cert" {
#   depends_on = [helm_release.rancher_server]

#   metadata {
#     name      = "tls-rancher-ingress"
#     namespace = "cattle-system"
#   }
# }
# data "rancher2_cluster_v2" "kube-config" {
#   provider = rancher2.admin
#   name = yamlencode(rancher2_cluster_v2.cluster-k8s.kube_config)
# }
