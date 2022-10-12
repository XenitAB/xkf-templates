terraform {
  backend "azurerm" {}
  required_version = "1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.24.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.28.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.3"
    }
    github = {
      source  = "integrations/github"
      version = "4.21.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "0.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
    azuredevops = {
      source  = "XenitAB/azuredevops"
      version = "0.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "random" {}

provider "tls" {}

provider "flux" {}

provider "kubernetes" {
  alias                  = "aks1"
  host                   = module.aks1.kube_config.host
  client_certificate     = module.aks1.kube_config.client_certificate
  client_key             = module.aks1.kube_config.client_key
  cluster_ca_certificate = module.aks1.kube_config.cluster_ca_certificate
}

provider "helm" {
  alias = "aks1"
  kubernetes {
    host                   = module.aks1.kube_config.host
    client_certificate     = module.aks1.kube_config.client_certificate
    client_key             = module.aks1.kube_config.client_key
    cluster_ca_certificate = module.aks1.kube_config.cluster_ca_certificate
  }
}

provider "kubectl" {
  alias                  = "aks1"
  host                   = module.aks1.kube_config.host
  client_certificate     = module.aks1.kube_config.client_certificate
  client_key             = module.aks1.kube_config.client_key
  cluster_ca_certificate = module.aks1.kube_config.cluster_ca_certificate
  load_config_file       = false
}

locals {
  aks_authorized_ips = concat([
    "20.50.34.176/32",  # Xenit Azure (CVAD)
    "51.138.51.65/32",  # Xenit Azure (VPN)
    "212.116.69.18/32", # Xenit GBG Office (GBG Primary)
    "212.116.69.27/32", # Xenit GBG Office (Secondary / VPN)
    "193.14.162.82/32", # Xenit GBG Office (4G)
  ], var.aks_authorized_ips)
}

module "xkf_governance_global_data" {
  source            = "github.com/xenitab/terraform-modules//modules/azure/xkf-governance-global-data?ref=2022.10.1"
  cloud_provider    = "azure"
  environment       = var.environment
  subscription_name = var.subscription_name
  namespaces = [for n in var.namespaces :
    {
      name                    = n.name
      delegate_resource_group = n.delegate_resource_group
    }
  ]
  group_name_prefix = var.aks_group_name_prefix
}
module "aks_regional" {
  source = "github.com/xenitab/terraform-modules//modules/azure/aks-regional?ref=2022.10.1"

  environment           = var.environment
  location_short        = var.location_short
  global_location_short = var.location_short
  name                  = var.name
  subscription_name     = var.subscription_name
  core_name             = var.core_name
  unique_suffix         = var.unique_suffix
  namespaces = [for n in var.namespaces :
    {
      name                    = n.name
      delegate_resource_group = n.delegate_resource_group
    }
  ]
  dns_zone              = var.dns_zones
  aks_authorized_ips    = local.aks_authorized_ips
  azure_ad_group_prefix = var.azure_ad_group_prefix
  aks_managed_identity  = module.xkf_governance_global_data.aad_groups.aks_managed_identity.id
}

module "aks1" {
  source = "github.com/xenitab/terraform-modules//modules/azure/aks?ref=2022.10.1"

  environment     = var.environment
  location_short  = var.location_short
  name            = var.name
  core_name       = var.core_name
  aks_name_suffix = 1
  unique_suffix   = var.unique_suffix

  aks_config                    = var.aks_config
  aks_public_ip_prefix_id       = module.aks_regional.aks_public_ip_prefix_ids[1]
  aks_authorized_ips            = local.aks_authorized_ips
  ssh_public_key                = module.aks_regional.ssh_public_key
  aks_managed_identity_group_id = module.aks_regional.aks_managed_identity_group_id
  aad_groups                    = module.xkf_governance_global_data.aad_groups
  namespaces                    = var.namespaces
  azure_metrics_identity = {
    principal_id = module.aks_regional.azure_metrics_identity.principal_id
    id           = module.aks_regional.azure_metrics_identity.resource_id
  }

  log_eventhub_authorization_rule_id = module.aks_regional.log_eventhub_authorization_rule_id
  log_eventhub_name                  = module.aks_regional.log_eventhub_name
}

module "aks1_core" {
  source = "github.com/xenitab/terraform-modules//modules/kubernetes/aks-core?ref=2022.10.1"
  providers = {
    kubernetes = kubernetes.aks1
    helm       = helm.aks1
    kubectl    = kubectl.aks1
  }

  azure_metrics_config = {
    client_id   = module.aks_regional.azure_metrics_identity.client_id
    resource_id = module.aks_regional.azure_metrics_identity.resource_id
  }

  environment                            = var.environment
  location_short                         = var.location_short
  name                                   = var.name
  aks_name_suffix                        = 1
  global_location_short                  = var.location_short
  kubernetes_network_policy_default_deny = false

  aad_groups = module.xkf_governance_global_data.aad_groups
  namespaces = [for n in var.namespaces :
    {
      name   = n.name
      labels = n.labels
      flux   = n.flux
    }
  ]
  aad_pod_identity_config = module.aks_regional.aad_pod_identity
  velero_config           = module.aks_regional.velero
  external_dns_config     = module.aks_regional.external_dns_identity

  fluxcd_v2_enabled = true
  fluxcd_v2_config  = local.fluxcd_v2_config

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
    tenant_id                       = "polestar"
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
    excluded_namespaces  = var.namespaces[*].name
  }

  opa_gatekeeper_config = {
    additional_excluded_namespaces = ["prometheus"]
    enable_default_constraints     = true
    additional_constraints         = []
    enable_default_assigns         = true
    additional_assigns             = []
  }

  grafana_agent_enabled = false
  grafana_agent_config  = local.grafana_agent_config
}
