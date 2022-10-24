provider "kubernetes" {
  alias                  = "aks2"
  host                   = module.aks2.kube_config.host
  client_certificate     = module.aks2.kube_config.client_certificate
  client_key             = module.aks2.kube_config.client_key
  cluster_ca_certificate = module.aks2.kube_config.cluster_ca_certificate
}

provider "helm" {
  alias = "aks2"
  kubernetes {
    host                   = module.aks2.kube_config.host
    client_certificate     = module.aks2.kube_config.client_certificate
    client_key             = module.aks2.kube_config.client_key
    cluster_ca_certificate = module.aks2.kube_config.cluster_ca_certificate
  }
}

provider "kubectl" {
  alias                  = "aks2"
  host                   = module.aks2.kube_config.host
  client_certificate     = module.aks2.kube_config.client_certificate
  client_key             = module.aks2.kube_config.client_key
  cluster_ca_certificate = module.aks2.kube_config.cluster_ca_certificate
  load_config_file       = false
}

module "aks2" {
  source = "github.com/xenitab/terraform-modules//modules/azure/aks?ref=2022.10.2"

  environment     = var.environment
  location_short  = var.location_short
  name            = local.name
  core_name       = var.core_name
  aks_name_suffix = 2
  unique_suffix   = var.unique_suffix

  aks_config                    = var.aks_config
  aks_public_ip_prefix_id       = module.aks_regional.aks_public_ip_prefix_ids[1]
  aks_authorized_ips            = var.aks_authorized_ips
  ssh_public_key                = module.aks_regional.ssh_public_key
  aks_managed_identity_group_id = module.aks_regional.aks_managed_identity_group_id
  aad_groups                    = module.xkf_governance_global_data.aad_groups
  namespaces                    = var.tenant_namespaces
  azure_metrics_identity = {
    principal_id = module.aks_regional.azure_metrics_identity.principal_id
    id           = module.aks_regional.azure_metrics_identity.resource_id
  }

  log_eventhub_authorization_rule_id = module.aks_regional.log_eventhub_authorization_rule_id
  log_eventhub_name                  = module.aks_regional.log_eventhub_name
}

module "aks2_core" {
  source = "github.com/xenitab/terraform-modules//modules/kubernetes/aks-core?ref=2022.10.2"
  providers = {
    kubernetes = kubernetes.aks2
    helm       = helm.aks2
    kubectl    = kubectl.aks2
  }

  azure_metrics_config = {
    client_id   = module.aks_regional.azure_metrics_identity.client_id
    resource_id = module.aks_regional.azure_metrics_identity.resource_id
  }

  environment                            = var.environment
  location_short                         = var.location_short
  name                                   = local.name
  aks_name_suffix                        = 2
  global_location_short                  = var.location_short
  kubernetes_network_policy_default_deny = var.kubernetes_network_policy_default_deny

  aad_groups = module.xkf_governance_global_data.aad_groups
  namespaces = [for n in var.tenant_namespaces :
    {
      name   = n.name
      labels = n.labels
      flux   = n.flux
    }
  ]
  aad_pod_identity_config = module.aks_regional.aad_pod_identity
  velero_config           = module.aks_regional.velero
  external_dns_config     = module.aks_regional.external_dns_identity

  fluxcd_v2_config = local.fluxcd_v2_config

  cert_manager_config = {
    notification_email = "DG-Team-DevOps@xenit.se"
    dns_zone           = var.dns_zones
  }

  azad_kube_proxy_enabled = true
  azad_kube_proxy_config = {
    fqdn                  = "aks-${var.location_short}.${var.dns_zones[0]}"
    azure_ad_group_prefix = var.aks_group_name_prefix
    allowed_ips           = var.aks_authorized_ips
    azure_ad_app          = module.aks_regional.azad_kube_proxy.azure_ad_app
  }

  ingress_config = var.ingress_config

  starboard_enabled = true
  starboard_config  = module.aks_regional.trivy_identity

  node_local_dns_enabled = true

  prometheus_enabled = true
  prometheus_config = {
    tenant_id                       = var.tenant_id
    remote_write_authenticated      = var.prometheus_config.remote_write_authenticated
    remote_write_url                = var.prometheus_config.remote_write_url
    volume_claim_storage_class_name = "managed-csi-zrs"
    volume_claim_size               = var.prometheus_config.volume_claim_size
    resource_selector               = var.prometheus_config.resource_selector
    namespace_selector              = var.prometheus_config.namespace_selector
    azure_key_vault_name            = module.aks_regional.xenit.azure_key_vault_name
    identity                        = module.aks_regional.xenit.identity
  }

  promtail_enabled = true
  promtail_config = {
    loki_address         = "https://logging.prod.unbox.xenit.io/loki/api/v1/push"
    azure_key_vault_name = module.aks_regional.xenit.azure_key_vault_name
    identity             = module.aks_regional.xenit.identity
    excluded_namespaces  = setsubtract(var.tenant_namespaces[*].name, var.promtail_included_tenant_namespaces)
  }

  opa_gatekeeper_config = var.opa_gatekeeper_config

  grafana_agent_enabled = local.grafana_agent_enabled
  grafana_agent_config  = local.grafana_agent_config
  datadog_enabled       = local.datadog_enabled
  datadog_config        = local.datadog_config

  control_plane_logs_enabled = var.control_plane_logs_enabled
  control_plane_logs_config = {
    azure_key_vault_name = module.aks_regional.xenit.azure_key_vault_name
    identity             = module.aks_regional.xenit.identity
    eventhub_hostname    = module.aks_regional.log_eventhub_hostname
    eventhub_name        = module.aks_regional.log_eventhub_name
  }

  node_ttl_enabled = var.node_ttl_enabled
}
