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
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.3"
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
  source                = "github.com/xenitab/terraform-modules//modules/azure/hub?ref=b7c5767b281d2d33f765ccf815ba83de251e9a69"
  environment           = var.environment
  location_short        = var.azure_location_short
  subscription_name     = var.azure_subscription_name
  azure_ad_group_prefix = var.azure_ad_group_prefix
  name                  = local.name
  vnet_config           = var.vnet_config
  peering_config        = var.peering_config
}
