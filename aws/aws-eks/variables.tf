variable "azure_subscription_name" {
  description = "The name of the subscription"
  type        = string
}

variable "tenant_id" {
  description = "The id of the tenant"
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

variable "aws_location" {
  description = "The name of the location"
  type        = string
}
variable "environment" {
  description = "The environment name to use for the deploy"
  type        = string
}

variable "eks_name" {
  description = "Common name for the environment"
  type        = string
  default     = "eks"
}

# tflint-ignore: terraform_unused_declarations
variable "core_name" {
  description = "The name of the core infra"
  type        = string
  default     = "core"
}

# tflint-ignore: terraform_unused_declarations
variable "azure_location" {
  description = "The name of the location"
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "azure_location_short" {
  description = "The short name of the location"
  type        = string
}

variable "eks_config" {
  description = "The EKS Config"
  type = object({
    version    = string
    cidr_block = string
    node_pools = list(object({
      name           = string
      version        = string
      min_size       = number
      max_size       = number
      instance_types = list(string)
      node_labels    = map(string)
      node_taints = list(object({
        key    = string
        value  = string
        effect = string
      }))
    }))
  })
}

variable "dns_zones" {
  description = "The DNS Zone to create"
  type        = list(string)
}

variable "tenant_namespaces" {
  description = "The tenant kubernetes namespaces"
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

variable "eks_authorized_ips" {
  description = "Authorized IPs to access EKS API"
  type        = list(string)
}

variable "ingress_config" {
  description = "Ingress configuration"
  type = object({
    http_snippet              = string
    public_private_enabled    = bool
    allow_snippet_annotations = bool
    extra_config              = map(string)
    extra_headers             = map(string)
  })
  default = {
    http_snippet              = ""
    public_private_enabled    = false
    allow_snippet_annotations = false
    extra_config              = {}
    extra_headers             = {}
  }
}

variable "prometheus_enabled" {
  description = "Should prometheus be enabled"
  type        = bool
  default     = true
}

variable "prometheus_config" {
  description = "Configuration for prometheus"
  type = object({
    remote_write_authenticated = bool
    remote_write_url           = string
    volume_claim_size          = string
    resource_selector          = list(string)
    namespace_selector         = list(string)
  })
  default = {
    namespace_selector         = ["platform"]
    remote_write_authenticated = true
    remote_write_url           = "https://metrics.prod.unbox.xenit.io/api/v1/receive"
    resource_selector          = ["platform"]
    volume_claim_size          = "5Gi"
  }
}

variable "promtail_enabled" {
  description = "Should promtail be enabled"
  type        = bool
  default     = true
}
