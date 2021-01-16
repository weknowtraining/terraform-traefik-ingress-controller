resource "kubernetes_service_account" "traefik-ingress-controller" {
  metadata {
    name      = "traefik-ingress-controller"
    namespace = var.namespace
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "traefik-ingress-controller" {
  metadata {
    name = "traefik-ingress-controller"
  }

  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "secrets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "traefik-ingress-controller" {
  metadata {
    name = "traefik-ingress-controller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "traefik-ingress-controller"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "traefik-ingress-controller"
    namespace = var.namespace
  }
}

resource "kubernetes_daemonset" "traefik-ingress-controller" {
  metadata {
    name      = "traefik-ingress-controller"
    namespace = var.namespace
    labels = {
      "k8s-app" = "traefik-ingress-lb"
    }
  }

  spec {
    selector {
      match_labels = {
        "k8s-app" = "traefik-ingress-lb"
        name      = "traefik-ingress-lb"
      }
    }

    template {
      metadata {
        labels = {
          "k8s-app" = "traefik-ingress-lb"
          name      = "traefik-ingress-lb"
        }
      }

      spec {
        service_account_name             = "traefik-ingress-controller"
        automount_service_account_token  = true
        termination_grace_period_seconds = 60

        container {
          image = var.image
          name  = "traefik-ingress-lb"

          port {
            name           = "http"
            container_port = var.port
            host_port      = var.port
          }

          security_context {
            capabilities {
              drop = ["ALL"]
              add  = ["NET_BIND_SERVICE"]
            }
          }

          readiness_probe {
            http_get {
              path = "/ping"
              port = var.port
            }
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = var.port
            }
          }

          args = compact([
            "--api",
            "--kubernetes",
            var.access_log ? "--accessLog" : "",
            "--logLevel=${var.log_level}",
            "--defaultentrypoints=http",
            "--entrypoints=Name:http Address::${var.port} Compress=true",
            "--ping",
            "--ping.entrypoint=http"
          ])
        }
      }
    }
  }
}

resource "kubernetes_service" "traefik-ingress-service" {
  metadata {
    name      = "traefik-ingress-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      "k8s-app" = "traefik-ingress-lb"
    }

    port {
      protocol = "TCP"
      port     = var.port
      name     = "http"
    }
  }
}
