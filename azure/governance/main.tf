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
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "governance_global" {
  source = "github.com/xenitab/terraform-modules//modules/azure/governance-global?ref=2023.03.1"

  environment                  = var.environment
  subscription_name            = var.subscription_name
  owner_service_principal_name = var.owner_service_principal_name
  resource_group_configs       = concat(var.platform_resource_group_configs, var.tenant_resource_group_configs)
  azure_ad_group_prefix        = var.azure_ad_group_prefix
  aks_group_name_prefix        = var.aks_group_name_prefix
  partner_id                   = var.partner_id
  delegate_sub_groups          = var.delegate_sub_groups
}

module "governance_regional" {
  source = "github.com/xenitab/terraform-modules//modules/azure/governance-regional?ref=2023.03.1"

  environment                  = var.environment
  location                     = var.location
  location_short               = var.location_short
  owner_service_principal_name = var.owner_service_principal_name
  core_name                    = var.core_name
  resource_group_configs       = concat(var.platform_resource_group_configs, var.tenant_resource_group_configs)
  unique_suffix                = var.unique_suffix
  azuread_groups               = module.governance_global.azuread_groups
  azuread_apps                 = module.governance_global.azuread_apps
  aad_sp_passwords             = module.governance_global.aad_sp_passwords
}

module "xkf_governance_global" {
  source = "github.com/xenitab/terraform-modules//modules/azure/xkf-governance-global?ref=2023.03.1"

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
  azuread_groups    = module.governance_global.azuread_groups
}
