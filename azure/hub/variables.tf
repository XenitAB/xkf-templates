variable "location_short" {
  description = "The short name of the location"
  type        = string
}

variable "subscription_name" {
  description = "The name of the subscription"
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

# tflint-ignore: terraform_unused_declarations
variable "aks_group_name_prefix" {
  description = "Prefix for AKS Azure AD groups"
  type        = string
}

variable "environment" {
  description = "The environment name to use for the deploy"
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "ghrunner_image_id" {
  description = "The image to use for the Github runners"
  type        = string
  default     = ""
}

# tflint-ignore: terraform_unused_declarations
variable "ghrunner_vmss_sku" {
  description = "The sku for github runner VMSS instances"
  type        = string
  default     = "Standard_F4s_v2"
}

variable "ghrunner_vmss_zones" {
  description = "The zones to place the VMSS instances"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "ghrunner_vmss_instances" {
  description = "The number of instances"
  type        = number
  default     = 1
}

variable "ghrunner_vmss_disk_size_gb" {
  description = "The disk size (in GB) for the VMSS instances"
  type        = number
  default     = 128
}

# tflint-ignore: terraform_unused_declarations
variable "azpagent_image_id" {
  description = "The image to use for the Azure Devops agent pools"
  type        = string
  default     = "/communityGalleries/xenit-7d3dd81e-0b94-4684-810c-0685bca1377f/images/azdo-agent/versions/1.0.0"
}

# tflint-ignore: terraform_unused_declarations
variable "azpagent_vmss_sku" {
  description = "The sku for azpagent VMSS instances"
  type        = string
  default     = "Standard_F4s_v2"
}

# tflint-ignore: terraform_unused_declarations
variable "azpagent_name" {
  description = "The commonName to use for the deploy"
  type        = string
  default     = "azpagent"
}

# tflint-ignore: terraform_unused_declarations
variable "keyvault_name" {
  description = "The keyvault name"
  type        = string
  default     = ""
}

variable "vnet_config" {
  description = "Address spaces used by virtual network."
  type = object({
    address_space = list(string)
    subnets = list(object({
      name              = string
      cidr              = string
      service_endpoints = list(string)
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
