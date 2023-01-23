terraform {
  backend "azurerm" {}
  required_version = "1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.31.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.38.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "aws" {
  region = var.aws_location
}

module "core" {
  source                       = "github.com/xenitab/terraform-modules//modules/aws/eks-core?ref=970facaa325b866206cabffd3db9a344e22f5578"
  environment                  = var.environment
  name                         = var.core_name
  dns_zone                     = var.dns_zones
  flow_log_enabled             = var.flow_log_enabled
  cidr_block                   = var.cidr_block
  vpc_peering_config_requester = var.vpc_peering_config_requester
}
