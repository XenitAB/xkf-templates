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
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

locals {
  name = "hub"
}

module "hub" {
  source                = "github.com/xenitab/terraform-modules//modules/azure/hub?ref=2023.10.2"
  environment           = var.environment
  location_short        = var.location_short
  subscription_name     = var.subscription_name
  azure_ad_group_prefix = var.azure_ad_group_prefix
  name                  = local.name
  vnet_config           = var.vnet_config
  peering_config        = var.peering_config
}
