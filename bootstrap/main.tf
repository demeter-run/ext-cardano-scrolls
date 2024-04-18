locals {
  network_version_combinations = [
    for combo in setproduct(var.networks, var.scrolls_versions) : {
      network = combo[0]
      version = combo[1]
    }
  ]
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

module "scrolls_v1_feature" {
  depends_on         = [kubernetes_namespace.namespace]
  source             = "./feature"
  namespace          = var.namespace
  operator_image_tag = var.operator_image_tag
  metrics_delay      = var.metrics_delay
  dns_zone           = var.dns_zone
  api_key_salt       = var.api_key_salt
  dcu_per_request    = var.dcu_per_request
  resources          = var.operator_resources
}

module "scrolls_v1_postgres" {
  depends_on                   = [kubernetes_namespace.namespace]
  source                       = "./postgres"
  namespace                    = var.namespace
  enable_master_load_balancer  = var.enable_master_load_balancer
  enable_replica_load_balancer = var.enable_replica_load_balancer
  postgres_resources           = var.postgres_resources
  postgres_params              = var.postgres_params
  postgres_volume              = var.postgres_volume
}

module "scrolls_v1_proxy" {
  depends_on      = [kubernetes_namespace.namespace, kubernetes_secret.tls_stuff]
  source          = "./proxy"
  proxy_image_tag = var.proxy_image_tag
  namespace       = var.namespace
  replicas        = var.proxy_replicas
  resources       = var.proxy_resources
  dns_zone        = var.dns_zone
  extension_name  = var.extension_name
}

module "scrolls_instances" {
  depends_on = [kubernetes_namespace.namespace, module.scrolls_v1_postgres]
  for_each   = var.instances
  source     = "./instance"

  namespace = var.namespace
  image_tag = each.value.image_tag
  salt      = each.value.salt
  network   = each.value.network
  replicas  = coalesce(each.value.replicas, 1)
  resources = coalesce(each.value.resources, {
    limits : {
      cpu : "200m",
      memory : "1Gi"
    }
    requests : {
      cpu : "200m",
      memory : "500Mi"
    }
  })
}

module "scrolls_services" {
  depends_on = [kubernetes_namespace.namespace]
  for_each   = { for i, nv in local.network_version_combinations : "${nv.network}-${nv.version}" => nv }
  source     = "./service"

  namespace       = var.namespace
  scrolls_version = each.value.version
  network         = each.value.network
}
