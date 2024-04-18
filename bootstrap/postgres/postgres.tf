resource "kubernetes_manifest" "postgres" {
  field_manager {
    force_conflicts = true
  }
  manifest = {
    "apiVersion" = "acid.zalan.do/v1"
    "kind"       = "postgresql"
    "metadata" = {
      "name"      = local.postgres_host
      "namespace" = var.namespace
    }
    "spec" = {
      "env" : [
        {
          "name" : "ALLOW_NOSSL"
          "value" : "true"
        }
      ]
      "numberOfInstances"         = var.postgres_replicas
      "enableMasterLoadBalancer"  = var.enable_master_load_balancer
      "enableReplicaLoadBalancer" = var.enable_replica_load_balancer
      "allowedSourceRanges" = [
        "0.0.0.0/0"
      ]
      "dockerImage" : "ghcr.io/zalando/spilo-15:3.2-p1"
      "teamId" = "dmtr"
      "tolerations" = [
        {
          "key"      = "demeter.run/workload"
          "operator" = "Equal"
          "value"    = "mem-intensive"
          "effect"   = "NoSchedule"
        },
        {
          "effect"   = "NoSchedule"
          "key"      = "demeter.run/compute-profile"
          "operator" = "Exists"
        },
        {
          "effect"   = "NoSchedule"
          "key"      = "demeter.run/compute-arch"
          "operator" = "Equal"
          "value"    = "arm64"
        },
        {
          "effect"   = "NoSchedule"
          "key"      = "demeter.run/availability-sla"
          "operator" = "Equal"
          "value"    = "consistent"
        }
      ]
      "serviceAnnotations" : {
        "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "instance"
        "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
        "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
      }
      "databases" = {
        "scrolls-mainnet" = "scrolls"
        "scrolls-preprod" = "scrolls"
        "scrolls-preview" = "scrolls"
      }
      "postgresql" = {
        "version"    = "14"
        "parameters" = var.postgres_params
      }
      "users" = {
        "scrolls" = [
          "superuser",
          "createdb",
          "login"
        ],
        "dmtrro" = [
          "login"
        ]
      }
      "resources" = {
        "limits"   = var.postgres_resources.limits
        "requests" = var.postgres_resources.requests
      }
      "volume" = {
        "storageClass" = var.postgres_volume.storage_class
        "size"         = var.postgres_volume.size
      }
      sidecars = [
        {
          name : "exporter"
          image : "quay.io/prometheuscommunity/postgres-exporter:v0.12.0"
          env : [
            {
              name : "DATA_SOURCE_URI"
              value : "localhost:5432/scrolls-mainnet?sslmode=disable"
            },
            {
              name : "DATA_SOURCE_USER"
              value : "$(POSTGRES_USER)"
            },
            {
              name : "DATA_SOURCE_PASS"
              value : "$(POSTGRES_PASSWORD)"
            },
            {
              name : "PG_EXPORTER_CONSTANT_LABELS"
              value : "service=${local.postgres_host}"
            }
          ]
          ports : [
            {
              name : "metrics"
              containerPort : 9187
            }
          ]
        }
      ]
    }
  }
}
