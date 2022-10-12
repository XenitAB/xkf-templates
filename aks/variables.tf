# tflint-ignore: terraform_unused_declarations
variable "location" {
  description = "The name of the location"
  type        = string
}

variable "location_short" {
  description = "The short name of the location"
  type        = string
}

variable "environment" {
  description = "The environment name to use for the deploy"
  type        = string
}

variable "name" {
  description = "The name to use for the deploy"
  type        = string
}

variable "subscription_name" {
  description = "The commonName for the subscription"
  type        = string
}

variable "core_name" {
  description = "The name for the core infrastructure"
  type        = string
}

variable "unique_suffix" {
  description = "Unique suffix that is used in globally unique resources names"
  type        = string
}

variable "azure_ad_group_prefix" {
  description = "Prefix for Azure AD Groupss"
  type        = string
}

variable "aks_group_name_prefix" {
  description = "Prefix for AKS Azure AD groups"
  type        = string
}

variable "namespaces" {
  description = "Tenant kubernetes namespaces."
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

variable "dns_zones" {
  description = "The DNS Zone to create"
  type        = list(string)
}

variable "aks_authorized_ips" {
  description = "Authorized IPs to access AKS API"
  type        = list(string)
}

variable "aks_config" {
  description = "The Azure Kubernetes Service (AKS) configuration"
  type = object({
    version          = string
    production_grade = bool
    node_pools = list(object({
      name           = string
      version        = string
      vm_size        = string
      min_count      = number
      max_count      = number
      spot_enabled   = bool
      spot_max_price = number
      node_taints    = list(string)
      node_labels    = map(string)
    }))
  })
  default = {
    node_pools = [{
      max_count = 1
      min_count = 1
      name      = "value"
      node_labels = {
        "key" = "value"
      }
      node_taints    = ["value"]
      spot_enabled   = false
      spot_max_price = 1
      version        = "value"
      vm_size        = "value"
    }]
    production_grade = false
    version          = "value"
  }
}
