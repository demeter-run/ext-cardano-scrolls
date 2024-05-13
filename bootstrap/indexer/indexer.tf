locals {
  name = "scrolls-indexer-${var.network}"
}

resource "kubernetes_deployment_v1" "indexer" {
  wait_for_rollout = false

  metadata {
    name      = local.name
    namespace = var.namespace
    labels = {
      "role"                        = "indexer"
      "demeter.run/kind"            = "ScrollsIndexer"
      "cardano.demeter.run/network" = var.network
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "role"                        = "indexer"
        "demeter.run/instance"        = local.name
        "cardano.demeter.run/network" = var.network
      }
    }

    template {

      metadata {
        name = local.name
        labels = {
          "role"                        = "indexer"
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
          name              = "indexer"
          image             = "ghcr.io/txpipe/asteria-indexer:${var.image_tag}"
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
            name  = "POSTGRES_DATABASE"
            value = "scrolls-${var.network}"
          }

          env {
            name  = "POSTGRES_PORT"
            value = "5432"
          }

          env {
            name  = "ConnectionStrings__CardanoContext"
            value = "Host=$(POSTGRES_HOST);Database=$(POSTGRES_DATABASE);Username=$(POSTGRES_USER);Password=$(POSTGRES_PASSWORD);Port=$(POSTGRES_PORT)"
          }

          env {
            name  = "ConnectionStrings__CardanoContextSchema"
            value = "public"
          }

          env {
            name  = "CardanoNodeSocketPath"
            value = "/ipc/node.socket"
          }

          env {
            name  = "CardanoNetworkMagic"
            value = var.testnet_magic
          }

          env {
            name  = "CardanoIndexStartSlot"
            value = var.index_start_slot
          }

          env {
            name  = "CardanoIndexStartHash"
            value = var.index_start_hash
          }

          env {
            name  = "ShipyardPolicyId"
            value = var.shipyard_policy_id
          }

          env {
            name  = "UtxoAddresses"
            value = var.utxo_adresses
          }

          volume_mount {
            name       = "ipc"
            mount_path = "/ipc"
          }
        }

        container {
          name  = "socat"
          image = "alpine/socat"
          args = [
            "UNIX-LISTEN:/ipc/node.socket,reuseaddr,fork,unlink-early",
            "TCP-CONNECT:${var.node_private_dns}"
          ]

          security_context {
            run_as_user  = 1000
            run_as_group = 1000
          }

          volume_mount {
            name       = "ipc"
            mount_path = "/ipc"
          }
        }

        volume {
          name = "ipc"
          empty_dir {}
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

