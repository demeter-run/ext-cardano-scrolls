locals {
  name = "scrolls-${var.network}-${var.salt}"
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
          image             = "${var.image}:${var.image_tag}"
          image_pull_policy = "IfNotPresent"

          args = [
            "--schema",
            "collections",
            "--watch",
            "--owner-connection",
            "postgres://$(POSTGRES_OWNER_USER):$(POSTGRES_OWNER_PASSWORD)@$(POSTGRES_HOST):5432/${var.postgres_database}"
          ]

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
            container_port = var.port
            name           = "api"
          }

          env {
            name = "POSTGRES_USER"

            value_from {
              secret_key_ref {
                key  = "username"
                name = var.dbcreds_secret_name
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "password"
                name = var.dbcreds_secret_name
              }
            }
          }

          env {
            name = "POSTGRES_OWNER_USER"
            value_from {
              secret_key_ref {
                key  = "username"
                name = var.ownercreds_secret_name
              }
            }
          }

          env {
            name = "POSTGRES_OWNER_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "password"
                name = var.ownercreds_secret_name
              }
            }
          }

          env {
            name  = "POSTGRES_HOST"
            value = var.postgres_host
          }

          env {
            name  = "POSTGRES_DATABASE"
            value = var.postgres_database
          }

          env {
            name  = "DATABASE_URL"
            value = "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@$(POSTGRES_HOST):5432/${var.postgres_database}"
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
          operator = "Exists"
        }
      }
    }
  }
}

