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
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress"
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
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  values = [
    "${file("../values.yaml")}"
  ]
  # set {
  #   name  = "create namespace"
  #   value = "true"
  # }

}