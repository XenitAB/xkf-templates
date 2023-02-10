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

module "core" {
  source = "github.com/xenitab/terraform-modules//modules/azure/core?ref=2de07c61ce0806fad23518627d4bc0128d875b44"

  environment           = var.environment
  location_short        = var.location_short
  subscription_name     = var.subscription_name
  name                  = var.core_name
  vnet_config           = var.vnet_config
  peering_config        = var.peering_config
  azure_ad_group_prefix = var.azure_ad_group_prefix
  unique_suffix         = var.unique_suffix
  alerts_enabled        = var.alerts_enabled
  notification_email    = "DG-Team-DevOps@xenit.se"
}
