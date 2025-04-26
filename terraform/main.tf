terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11.0"
    }
  }
}

provider "kubernetes" {
  host                   = "https://${var.k8s_host}"
  cluster_ca_certificate = base64decode(var.k8s_ca_certificate)
  client_key             = base64decode(var.k8s_client_key)
  client_certificate     = base64decode(var.k8s_client_certificate)
}

resource "kubernetes_namespace" "devops_demo" {
  metadata {
    name = "devops-demo"
  }
}

resource "kubernetes_deployment" "nginx_app" {
  metadata {
    name      = "nginx-app"
    namespace = kubernetes_namespace.devops_demo.metadata[0].name
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx-local:dev"
          port {
            container_port = 80
          }
        }

        container {
          name  = "nginx-exporter"
          image = "nginx/nginx-prometheus-exporter:1.1.0"
          args = [
            "-nginx.scrape-uri=http://127.0.0.1/nginx_status"
          ]
          port {
            container_port = 9113
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_service" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.devops_demo.metadata[0].name
  }

  spec {
    selector = {
      app = "nginx"
    }

    type = "NodePort"

    port {
      name        = "http"
      port        = 80
      target_port = 80
      node_port   = 30080
    }

    port {
      name        = "metrics"
      port        = 9113
      target_port = 9113
      node_port   = 30913
    }
  }
}
