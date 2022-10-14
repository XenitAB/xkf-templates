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
  source                = "github.com/xenitab/terraform-modules//modules/azure/hub?ref=2022.10.1"
  environment           = var.environment
  location_short        = var.location_short
  subscription_name     = var.subscription_name
  azure_ad_group_prefix = var.azure_ad_group_prefix
  name                  = local.name
  vnet_config           = var.vnet_config
  peering_config        = var.peering_config
}

module "azpagent" {
  source            = "github.com/xenitab/terraform-modules//modules/azure/azure-pipelines-agent-vmss?ref=2022.10.1"
  environment       = var.environment
  location_short    = var.location_short
  unique_suffix     = var.unique_suffix
  name              = "azpagent"
  source_image_id   = "/communityGalleries/xenit-7d3dd81e-0b94-4684-810c-0685bca1377f/images/azdo-agent/versions/1.0.0"
  vmss_sku          = "Standard_F4s_v2"
  vmss_disk_size_gb = 64
  vmss_subnet_id    = module.hub.subnets["sn-${var.environment}-${var.location_short}-${local.name}-servers"].id
}
