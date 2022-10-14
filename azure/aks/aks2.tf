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
  source = "github.com/xenitab/terraform-modules//modules/azure/aks?ref=2022.10.1"

  environment     = var.environment
  location_short  = var.location_short
  name            = local.name
  core_name       = local.core_name
  aks_name_suffix = 2
  unique_suffix   = var.unique_suffix

  aks_config                    = var.aks_config
  aks_public_ip_prefix_id       = module.aks_regional.aks_public_ip_prefix_ids[1]
  aks_authorized_ips            = local.aks_authorized_ips
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
  source = "github.com/xenitab/terraform-modules//modules/kubernetes/aks-core?ref=2022.10.1"
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
  kubernetes_network_policy_default_deny = false

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
    allowed_ips           = local.aks_authorized_ips
    azure_ad_app          = module.aks_regional.azad_kube_proxy.azure_ad_app
  }

  starboard_enabled = true
  starboard_config  = module.aks_regional.trivy_identity

  node_local_dns_enabled = true

  prometheus_enabled = true
  prometheus_config = {
    tenant_id                       = var.tenant_id
    remote_write_authenticated      = true
    remote_write_url                = "https://metrics.prod.unbox.xenit.io/api/v1/receive"
    volume_claim_storage_class_name = "managed-csi-zrs"
    volume_claim_size               = "5Gi"
    resource_selector               = ["platform"]
    namespace_selector              = ["platform"]
    azure_key_vault_name            = module.aks_regional.xenit.azure_key_vault_name
    identity                        = module.aks_regional.xenit.identity
  }

  promtail_enabled = true
  promtail_config = {
    loki_address         = "https://logging.prod.unbox.xenit.io/loki/api/v1/push"
    azure_key_vault_name = module.aks_regional.xenit.azure_key_vault_name
    identity             = module.aks_regional.xenit.identity
    excluded_namespaces  = var.tenant_namespaces[*].name
  }

  opa_gatekeeper_config = {
    additional_excluded_namespaces = ["prometheus"]
    enable_default_constraints     = true
    additional_constraints         = []
    enable_default_assigns         = true
    additional_assigns             = []
  }

  grafana_agent_config = local.grafana_agent_config
  datadog_config       = local.datadog_config
}
