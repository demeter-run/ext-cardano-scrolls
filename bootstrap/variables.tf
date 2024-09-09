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

variable "scrolls_port" {
  type    = number
  default = 8000
}

variable "dbcreds" {
  type = object({
    username = string
    password = string
  })
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
    image         = optional(string)
    image_tag     = optional(string)
    salt          = string
    network       = string
    postgres_host = string
    replicas      = optional(number)
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
