variable "namespace" {
  type = string
}

variable "dns_zone" {
  type    = string
  default = "demeter.run"
}

variable "extension_name" {
  type    = string
  default = "scrolls-m0"
}

variable "networks" {
  type    = list(string)
  default = ["mainnet", "preprod", "preview", "vector-testnet"]
}

variable "scrolls_versions" {
  type    = list(string)
  default = ["v0"]
}

// Operator
variable "operator_image_tag" {
  type = string
}

variable "api_key_salt" {
  type = string
}

variable "dcu_per_request" {
  type = map(string)
  default = {
    "mainnet"        = "10"
    "preprod"        = "5"
    "preview"        = "5"
    "sanchonet"      = "5"
    "vector-testnet" = "5"
  }
}

variable "metrics_delay" {
  type    = number
  default = 60
}

variable "operator_resources" {
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
    limits = {
      cpu    = "1"
      memory = "512Mi"
    }
    requests = {
      cpu    = "50m"
      memory = "512Mi"
    }
  }
}

// Proxy
variable "proxy_image_tag" {
  type = string
}

variable "proxy_replicas" {
  type    = number
  default = 1
}

variable "proxy_resources" {
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
      cpu : "50m",
      memory : "250Mi"
    }
    requests : {
      cpu : "50m",
      memory : "250Mi"
    }
  }
}

variable "instances" {
  type = map(object({
    image_tag          = optional(string)
    salt               = string
    network            = string
    replicas           = optional(number)
    resources = optional(object({
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    }))
  }))
}

variable "indexers" {
  type = map(object({
    image_tag          = optional(string)
    network            = string
    testnet_magic      = string
    index_start_slot   = number
    index_start_hash   = string
    shipyard_policy_id = string
    utxo_adresses      = string
    node_private_dns   = string
    postgres_host      = string
    resources = optional(object({
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    }))
  }))
}

// Postgres
variable "enable_master_load_balancer" {
  type    = bool
  default = false
}

variable "enable_replica_load_balancer" {
  type    = bool
  default = false
}

variable "postgres_resources" {
  type = object({
    requests = map(string)
    limits   = map(string)
  })

  default = {
    "limits" = {
      memory = "2Gi"
      cpu    = "4000m"
    }
    "requests" = {
      memory = "2Gi"
      cpu    = "100m"
    }
  }
}

variable "postgres_params" {
  default = {
    "max_standby_archive_delay"   = "900s"
    "max_standby_streaming_delay" = "900s"
  }
}

variable "postgres_volume" {
  type = object({
    storage_class = string
    size          = string
  })

  default = {
    storage_class = "fast"
    size          = "30Gi"
  }
}

variable "postgres_replicas" {
  type    = number
  default = 2
}
