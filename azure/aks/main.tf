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

locals {
  aks_authorized_ips = concat([
    "20.50.34.176/32",  # Xenit Azure (CVAD)
    "51.138.51.65/32",  # Xenit Azure (VPN)
    "212.116.69.18/32", # Xenit GBG Office (GBG Primary)
    "212.116.69.27/32", # Xenit GBG Office (Secondary / VPN)
    "193.14.162.82/32", # Xenit GBG Office (4G)
  ], var.aks_authorized_ips)
  name      = "aks"
  core_name = "core"
}

module "xkf_governance_global_data" {
  source            = "github.com/xenitab/terraform-modules//modules/azure/xkf-governance-global-data?ref=2022.10.1"
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
  source = "github.com/xenitab/terraform-modules//modules/azure/aks-regional?ref=2022.10.1"

  environment           = var.environment
  location_short        = var.location_short
  global_location_short = var.location_short
  name                  = local.name
  subscription_name     = var.subscription_name
  core_name             = local.core_name
  unique_suffix         = var.unique_suffix
  namespaces = [for n in var.tenant_namespaces :
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

