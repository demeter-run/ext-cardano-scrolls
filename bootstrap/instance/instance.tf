locals {
  name           = "scrolls-${var.network}-${var.salt}"
  container_port = 8000
}

resource "kubernetes_deployment_v1" "scrolls" {
  wait_for_rollout = false

  metadata {
    name      = local.name
    namespace = var.namespace
    labels = {
      "role"                        = "instance"
      "demeter.run/kind"            = "ScrollsInstance"
      "cardano.demeter.run/network" = var.network
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        "role"                        = "instance"
        "demeter.run/instance"        = local.name
        "cardano.demeter.run/network" = var.network
      }
    }

    template {

      metadata {
        name = local.name
        labels = {
          "role"                        = "instance"
          "demeter.run/instance"        = local.name
          "cardano.demeter.run/network" = var.network
        }
      }

      spec {
        restart_policy = "Always"

        security_context {
          fs_group = 1000
        }

        container {
          name              = "main"
          image             = "ghcr.io/txpipe/asteria-backend:${var.image_tag}"
          image_pull_policy = "IfNotPresent"

          resources {
            limits = {
              cpu    = var.resources.limits.cpu
              memory = var.resources.limits.memory
            }
            requests = {
              cpu    = var.resources.requests.cpu
              memory = var.resources.requests.memory
            }
          }

          port {
            container_port = local.container_port
            name           = "api"
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "password"
                name = "scrolls.${var.postgres_host}.credentials.postgresql.acid.zalan.do"
              }
            }
          }

          env {
            name  = "POSTGRES_HOST"
            value = var.postgres_host
          }

          env {
            name  = "POSTGRES_USER"
            value = "scrolls"
          }

          env {
            name  = "DATABASE_URL"
            value = "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@$(POSTGRES_HOST):5432/scrolls-${var.network}"
          }
          
          env {
            name = "ROCKET_ADDRESS"
            value = "0.0.0.0"
          }
        }


        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-profile"
          operator = "Equal"
          value    = "general-purpose"
        }

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-arch"
          operator = "Equal"
          value    = "x86"
        }

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/availability-sla"
          operator = "Equal"
          value    = "consistent"
        }
      }
    }
  }
}

