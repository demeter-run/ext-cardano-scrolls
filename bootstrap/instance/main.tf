variable "namespace" {
  type = string
}

variable "salt" {
  type = string
}

variable "network" {
  type = string

  validation {
    condition     = contains(["mainnet", "preprod", "preview"], var.network)
    error_message = "Invalid network. Allowed values are mainnet, preprod, preview."
  }
}

variable "image" {
  type    = string
  default = "ghcr.io/demeter-run/ext-cardano-scrolls-instance"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "port" {
  type    = number
  default = 8000
}

variable "postgres_host" {
  type    = string
  default = "dmtr-postgres-scrolls"
}

variable "replicas" {
  type    = number
  default = 1
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
