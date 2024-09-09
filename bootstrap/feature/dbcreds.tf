resource "kubernetes_secret" "dbcreds" {
  metadata {
    namespace = var.namespace
    name      = var.dbcreds_secret_name
  }

  data = {
    username = var.dbcreds.username
    password = var.dbcreds.password
  }

  type = "Opaque"
}


