resource "kubernetes_secret" "dbcreds" {
  metadata {
    namespace = var.namespace
    name      = var.dbcreds_secret_name
  }

  data = {
    username = var.dbsync_creds.username
    password = var.dbsync_creds.password
  }

  type = "Opaque"
}


