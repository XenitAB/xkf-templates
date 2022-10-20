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
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

locals {
  resource_group_configs = [
    {
      common_name                = "core",
      delegate_aks               = false,
      delegate_key_vault         = true,
      delegate_service_endpoint  = false,
      delegate_service_principal = false,
      lock_resource_group        = false,
      disable_unique_suffix      = false,
      tags = {
        "description" = "Core infrastructure"
      }
    },
    {
      common_name                = "log",
      delegate_aks               = false,
      delegate_key_vault         = false,
      delegate_service_endpoint  = false,
      delegate_service_principal = false,
      lock_resource_group        = true,
      disable_unique_suffix      = false,
      tags = {
        "description" = "Managing logs"
      }
    },
    {
      common_name                = "hub",
      delegate_aks               = false,
      delegate_key_vault         = true,
      delegate_service_endpoint  = false,
      delegate_service_principal = false,
      lock_resource_group        = false,
      disable_unique_suffix      = false,
      tags = {
        "description" = "Hub for SPOF infra"
      }
    },
    {
      common_name                = "aks",
      delegate_aks               = false,
      delegate_key_vault         = true,
      delegate_service_endpoint  = false,
      delegate_service_principal = false,
      lock_resource_group        = false,
      disable_unique_suffix      = false,
      tags = {
        "description" = "Azure Kubernetes Service"
      }
    },
  ]
  core_name = "core"
}

module "governance_global" {
  source = "github.com/xenitab/terraform-modules//modules/azure/governance-global?ref=2022.10.1"

  environment                  = var.environment
  subscription_name            = var.subscription_name
  owner_service_principal_name = var.owner_service_principal_name
  resource_group_configs       = concat(local.resource_group_configs, var.tenant_resource_group_configs)
  azure_ad_group_prefix        = var.azure_ad_group_prefix
  aks_group_name_prefix        = var.aks_group_name_prefix
  partner_id                   = var.partner_id
  delegate_sub_groups          = var.delegate_sub_groups
}

module "governance_regional" {
  source = "github.com/xenitab/terraform-modules//modules/azure/governance-regional?ref=2022.10.1"

  environment                  = var.environment
  location                     = var.location
  location_short               = var.location_short
  owner_service_principal_name = var.owner_service_principal_name
  core_name                    = local.core_name
  resource_group_configs       = concat(local.resource_group_configs, var.tenant_resource_group_configs)
  unique_suffix                = var.unique_suffix
  azuread_groups               = module.governance_global.azuread_groups
  azuread_apps                 = module.governance_global.azuread_apps
  aad_sp_passwords             = module.governance_global.aad_sp_passwords
}

module "xkf_governance_global" {
  source            = "github.com/xenitab/terraform-modules//modules/azure/xkf-governance-global?ref=2022.10.1"
  cloud_provider    = "azure"
  environment       = var.environment
  subscription_name = var.subscription_name
  namespaces = [for n in var.tenant_namespaces :
    {
      name                    = n.name
      delegate_resource_group = n.delegate_resource_group
    }
  ]
  azure_ad_group_prefix = var.azure_ad_group_prefix
  group_name_prefix     = var.aks_group_name_prefix
}
