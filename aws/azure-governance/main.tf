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
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

locals {
  platform_resource_group_configs = [
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
      common_name                = "hub",
      delegate_aks               = false,
      delegate_key_vault         = true,
      delegate_service_endpoint  = false,
      delegate_service_principal = false,
      lock_resource_group        = false,
      disable_unique_suffix      = false,
      tags = {
        "description" = "Network for Azure Pipelines Agent"
      }
    },
  ]
}

module "governance_global" {
  source = "github.com/xenitab/terraform-modules//modules/azure/governance-global?ref=2023.10.2"

  environment                  = var.environment
  subscription_name            = var.azure_subscription_name
  owner_service_principal_name = var.owner_service_principal_name
  resource_group_configs       = concat(local.platform_resource_group_configs, var.tenant_resource_group_configs)
  azure_ad_group_prefix        = var.azure_ad_group_prefix
  aks_group_name_prefix        = var.aks_group_name_prefix
  partner_id                   = var.partner_id
  delegate_sub_groups          = false
}

module "governance_regional" {
  source = "github.com/xenitab/terraform-modules//modules/azure/governance-regional?ref=2023.10.2"

  environment                  = var.environment
  location                     = var.azure_location
  location_short               = var.azure_location_short
  owner_service_principal_name = var.owner_service_principal_name
  core_name                    = var.core_name
  resource_group_configs       = concat(local.platform_resource_group_configs, var.tenant_resource_group_configs)
  unique_suffix                = var.unique_suffix
  azuread_groups               = module.governance_global.azuread_groups
  azuread_apps                 = module.governance_global.azuread_apps
  aad_sp_passwords             = module.governance_global.aad_sp_passwords
}

module "xkf_governance_global" {
  source            = "github.com/xenitab/terraform-modules//modules/azure/xkf-governance-global?ref=2023.10.2"
  cloud_provider    = "aws"
  environment       = var.environment
  subscription_name = var.azure_subscription_name
  namespaces = [for n in var.tenant_namespaces :
    {
      name                    = n.name
      delegate_resource_group = n.delegate_resource_group
    }
  ]
  group_name_prefix = var.aks_group_name_prefix
  azuread_groups    = module.governance_global.azuread_groups
}
