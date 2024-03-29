terraform {
  backend "azurerm" {}
  required_version = "1.3.0"
  required_providers {
    azuredevops = {
      source  = "XenitAB/azuredevops"
      version = "0.5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.71.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.31.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "0.25.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.34.0"
    }
    git = {
      source  = "xenitab/git"
      version = ">=0.0.3"
    }
  }
}



provider "azurerm" {
  features {}
}

provider "aws" {
  region = var.aws_location
}

provider "aws" {
  alias = "eks_admin"

  region = var.aws_location
  assume_role {
    role_arn = module.eks_global.eks_admin_role_arn
  }
}

module "xkf_governance_global_data" {
  source            = "github.com/xenitab/terraform-modules//modules/azure/xkf-governance-global-data?ref=2023.10.2"
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
}

module "eks_global" {
  source = "github.com/xenitab/terraform-modules//modules/aws/eks-global?ref=2023.10.2"

  environment                    = var.environment
  name                           = var.eks_name
  unique_suffix                  = var.unique_suffix
  eks_admin_assume_principal_ids = local.eks_admin_assume_principal_ids
  dns_zone                       = var.dns_zones
}
