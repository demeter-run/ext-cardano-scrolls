locals {
  service_name = "scrolls-${var.scrolls_version}-${var.network}"
  port         = 8000
}

variable "namespace" {
  description = "The namespace where the resources will be created"
}

variable "scrolls_version" {
  description = "Version of the scrolls service."
}

variable "network" {
  description = "Cardano node network"

  validation {
    condition     = contains(["mainnet", "preprod", "preview", "vector-testnet"], var.network)
    error_message = "Invalid network. Allowed values are mainnet, preprod, preview, vector-testnet."
  }
}

resource "kubernetes_service_v1" "well_known_service" {
  metadata {
    name      = local.service_name
    namespace = var.namespace
  }

  spec {
    port {
      name     = "api"
      protocol = "TCP"
      port     = local.port
    }

    selector = {
      "cardano.demeter.run/network" = var.network
    }

    type = "ClusterIP"
  }
}
