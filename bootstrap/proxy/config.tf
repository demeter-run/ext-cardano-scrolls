// numbers here should consider number of proxy replicas
locals {
  tiers = [
    {
      "name" = "0",
      "rates" = [
        {
          "interval" = "1m",
          "limit"    = 60
        },
        {
          "interval" = "1d",
          "limit"    = 25000
        }
      ]
    },
    {
      "name" = "1",
      "rates" = [{
        "interval" = "1m",
        "limit"    = 500
      }]
    },
    {
      "name" = "2",
      "rates" = [{
        "interval" = "1m",
        "limit"    = 1000
      }]
    }
  ]
}

resource "kubernetes_config_map" "proxy" {
  metadata {
    namespace = var.namespace
    name      = "proxy-config"
  }

  data = {
    "tiers.toml" = "${templatefile("${path.module}/proxy-config.toml.tftpl", { tiers = local.tiers })}"
  }
}
