terraform {
  backend "azurerm" {}
  required_version = "1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.71.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.41.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    github = {
      source  = "integrations/github"
      version = "5.34.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "0.25.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
    azuredevops = {
      source  = "XenitAB/azuredevops"
      version = "0.5.0"
    }
    git = {
      source  = "xenitab/git"
      version = ">=0.0.3"
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
  source            = "github.com/xenitab/terraform-modules//modules/azure/xkf-governance-global-data?ref=2023.10.2"
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
  source = "github.com/xenitab/terraform-modules//modules/azure/aks-regional?ref=2023.10.2"

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
