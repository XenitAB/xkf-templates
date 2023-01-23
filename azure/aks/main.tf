terraform {
  backend "azurerm" {}
  required_version = "1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.38.0"
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


module "xkf_governance_global_data" {
  source            = "github.com/xenitab/terraform-modules//modules/azure/xkf-governance-global-data?ref=970facaa325b866206cabffd3db9a344e22f5578"
  cloud_provider    = "azure"
  environment       = var.environment
  subscription_name = var.subscription_name
  namespaces = [for n in var.tenant_namespaces :
    {
      name                    = n.name
      delegate_resource_group = n.delegate_resource_group
    }
  ]
  group_name_prefix = var.aks_group_name_prefix
}
module "aks_regional" {
  source = "github.com/xenitab/terraform-modules//modules/azure/aks-regional?ref=970facaa325b866206cabffd3db9a344e22f5578"

  environment           = var.environment
  location_short        = var.location_short
  global_location_short = var.location_short
  name                  = var.aks_name
  subscription_name     = var.subscription_name
  core_name             = var.core_name
  unique_suffix         = var.unique_suffix
  namespaces = [for n in var.tenant_namespaces :
    {
      name                    = n.name
      delegate_resource_group = n.delegate_resource_group
    }
  ]
  dns_zone              = var.dns_zones
  aks_authorized_ips    = var.aks_authorized_ips
  azure_ad_group_prefix = var.azure_ad_group_prefix
  aks_managed_identity  = module.xkf_governance_global_data.aad_groups.aks_managed_identity.id
  acr_name_override     = var.acr_name_override

  public_ip_prefix_configuration = var.public_ip_prefix_configuration
}
