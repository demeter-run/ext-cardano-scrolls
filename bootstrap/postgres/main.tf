locals {
  postgres_host = "dmtr-postgres-scrolls"
}

variable "namespace" {
  type = string
}

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
      memory = "4Gi"
      cpu    = "4000m"
    }
    "requests" = {
      memory = "4Gi"
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
