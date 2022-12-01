terraform {
  backend "azurerm" {}
  required_version = "1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.28.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.28.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "random" {}

provider "tls" {}

module "xkf_governance_global_data" {
  source            = "github.com/xenitab/terraform-modules//modules/azure/xkf-governance-global-data?ref=2022.12.1"
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

module "aks_global" {
  source                = "github.com/xenitab/terraform-modules//modules/azure/aks-global?ref=2022.12.1"
  environment           = var.environment
  location              = var.location
  location_short        = var.location_short
  unique_suffix         = var.unique_suffix
  dns_zone              = var.dns_zones
  name                  = var.aks_name
  aks_managed_identity  = module.xkf_governance_global_data.aad_groups.aks_managed_identity.id
  subscription_name     = var.subscription_name
  aks_group_name_prefix = var.aks_group_name_prefix
}

