variable "namespace" {
  type = string
}

variable "network" {
  type = string

  validation {
    condition     = contains(["mainnet", "preprod", "preview"], var.network)
    error_message = "Invalid network. Allowed values are mainnet, preprod, preview."
  }
}

variable "image_tag" {
  type = string
}

variable "testnet_magic" {
  type = string
}

variable "index_start_slot" {
  type = number
}

variable "index_start_hash" {
  type = string
}

variable "utxo_adresses" {
  type = string
}

variable "node_private_dns" {
  type = string
}

variable "postgres_host" {
  type    = string
  default = "dmtr-postgres-scrolls"
}

variable "resources" {
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits : {
      cpu : "200m",
      memory : "1Gi"
    }
    requests : {
      cpu : "200m",
      memory : "500Mi"
    }
  }
}

