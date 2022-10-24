# tflint-ignore: terraform_unused_declarations
variable "location" {
  description = "The name of the location"
  type        = string
}

variable "location_short" {
  description = "The short name of the location"
  type        = string
}

variable "subscription_name" {
  description = "The name of the subscription"
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "unique_suffix" {
  description = "Unique suffix that is used in globally unique resources names"
  type        = string
}

variable "core_name" {
  description = "The name of the core infra"
  type        = string
  default     = "core"
}

variable "azure_ad_group_prefix" {
  description = "Prefix for Azure AD Groupss"
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "aks_group_name_prefix" {
  description = "Prefix for AKS Azure AD groups"
  type        = string
}

variable "environment" {
  description = "The environment name to use for the deploy"
  type        = string
}

variable "vnet_config" {
  description = "Address spaces used by virtual network."
  type = object({
    address_space = list(string)
    dns_servers   = list(string)
    subnets = list(object({
      name              = string
      cidr              = string
      service_endpoints = list(string)
      aks_subnet        = bool
    }))
  })
}

variable "peering_config" {
  description = "Peering configuration"
  type = list(object({
    name                         = string
    remote_virtual_network_id    = string
    allow_forwarded_traffic      = bool
    use_remote_gateways          = bool
    allow_virtual_network_access = bool
  }))
  default = []
}
