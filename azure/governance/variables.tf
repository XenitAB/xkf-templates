variable "location" {
  description = "The name of the location"
  type        = string
}

variable "location_short" {
  description = "The short name of the location"
  type        = string
}

variable "core_name" {
  description = "The name of the core infra"
  type        = string
  default     = "core"
}

variable "subscription_name" {
  description = "The name of the subscription"
  type        = string
}

variable "unique_suffix" {
  description = "Unique suffix that is used in globally unique resources names"
  type        = string
}

variable "aks_group_name_prefix" {
  description = "Prefix for AKS Azure AD groups"
  type        = string
}

variable "environment" {
  description = "The environment to use for the deploy"
  type        = string
}

variable "delegate_sub_groups" {
  description = "Should the subscription groups be delegated to global groups (example: az-sub-[subName]-all-owner)"
  type        = bool
  default     = false
}

variable "tenant_resource_group_configs" {
  description = "Resource group configuration"
  type = list(
    object({
      common_name                        = string
      delegate_aks                       = bool # Delegate aks permissions
      delegate_key_vault                 = bool # Delegate KeyVault creation
      delegate_service_endpoint          = bool # Delegate Service Endpoint permissions
      delegate_service_principal         = bool # Delegate Service Principal
      lock_resource_group                = bool # Adds management_lock (CanNotDelete) to the resource group
      disable_unique_suffix              = bool
      key_vault_purge_protection_enabled = optional(bool, false)
      tags                               = map(string)
    })
  )
}

variable "platform_resource_group_configs" {
  description = "Resource group configuration"
  type = list(
    object({
      common_name                        = string
      delegate_aks                       = bool # Delegate aks permissions
      delegate_key_vault                 = bool # Delegate KeyVault creation
      delegate_service_endpoint          = bool # Delegate Service Endpoint permissions
      delegate_service_principal         = bool # Delegate Service Principal
      lock_resource_group                = bool # Adds management_lock (CanNotDelete) to the resource group
      disable_unique_suffix              = bool
      key_vault_purge_protection_enabled = optional(bool, false)
      tags                               = map(string)
    })
  )
  default = [
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
}
variable "owner_service_principal_name" {
  description = "The name of the service principal that will be used to run terraform and is owner of the subsciptions"
  type        = string
}

variable "partner_id" {
  description = "The Azure Partner ID"
  type        = string
}

variable "tenant_namespaces" {
  description = "The tenant namespaces"
  type = list(
    object({
      name                    = string
      delegate_resource_group = bool
      labels                  = map(string)
      flux = object({
        enabled     = bool
        create_crds = bool
        azure_devops = object({
          org  = string
          proj = string
          repo = string
        })
        github = object({
          repo = string
        })
      })
    })
  )
}
