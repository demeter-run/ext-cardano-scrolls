resource "kubernetes_config_map" "scrolls" {
  metadata {
    namespace = var.namespace
    name      = "scrolls-config"
  }

  data = {
    "schema.graphql" = file("${path.module}/schema.graphql")
  }
}
