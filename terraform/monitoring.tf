provider "helm" {
  kubernetes {
    host                   = "https://${var.k8s_host}"
    cluster_ca_certificate = base64decode(var.k8s_ca_certificate)
    client_key             = base64decode(var.k8s_client_key)
    client_certificate     = base64decode(var.k8s_client_certificate)
  }
}
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.devops_demo.metadata[0].name
  create_namespace = false
}
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.devops_demo.metadata[0].name
  create_namespace = false

  set {
    name  = "service.type"
    value = "NodePort"
  }

  set {
    name  = "service.nodePort"
    value = "30081"
  }
}
