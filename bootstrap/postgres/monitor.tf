resource "kubernetes_manifest" "postgres_podmonitor" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "PodMonitor"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "o11y"
        "app.kubernetes.io/part-of"   = "demeter"
      }
      "name"      = local.postgres_host
      "namespace" = var.namespace
    }
    "spec" = {
      podMetricsEndpoints = [
        {
          port = "metrics",
          path = "/metrics"
        }
      ]
      "selector" = {
        "matchLabels" = {
          "cluster-name" = local.postgres_host
        }
      }
    }
  }
}
