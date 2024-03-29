variable "tenant_id" {
  description = "The id of the tenant"
  type        = string
}

variable "location_short" {
  description = "The short name of the location"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "subscription_name" {
  description = "The commonName for the subscription"
  type        = string
}

variable "unique_suffix" {
  description = "Unique suffix that is used in globally unique resources names"
  type        = string
}

variable "aks_name" {
  description = "The name of AKS deployment"
  type        = string
  default     = "aks"
}

variable "core_name" {
  description = "The name of the core infra"
  type        = string
  default     = "core"
}

variable "azure_ad_group_prefix" {
  description = "Prefix for Azure AD Groups"
  type        = string
}

variable "aks_group_name_prefix" {
  description = "Prefix for AKS Azure AD groups"
  type        = string
}

variable "tenant_namespaces" {
  description = "Tenant kubernetes namespaces"
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
  description = "The DNS Zones"
  type        = list(string)
}

variable "aks_authorized_ips" {
  description = "Authorized IPs to access AKS API"
  type        = list(string)
}

variable "aks_default_node_pool_zones" {
  description = "The default node pool zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "aks_config" {
  description = "The Azure Kubernetes Service (AKS) configuration"
  type = object({
    version                  = string
    production_grade         = bool
    priority_expander_config = optional(map(list(string)))
    node_pools = list(object({
      name           = string
      version        = string
      vm_size        = string
      zones          = optional(list(string), ["1", "2", "3"])
      min_count      = number
      max_count      = number
      spot_enabled   = bool
      spot_max_price = number
      node_taints    = list(string)
      node_labels    = map(string)
    }))
  })
}

variable "gatekeeper_config" {
  description = "Configuration for OPA Gatekeeper"
  type = object({
    exclude_namespaces = list(string)
  })
  default = {
    exclude_namespaces = []
  }
}

variable "ingress_nginx_config" {
  description = "Ingress configuration"
  type = object({
    public_private_enabled = optional(bool, false)
    customization = optional(object({
      allow_snippet_annotations = optional(bool, false)
      http_snippet              = optional(string, "")
      extra_config              = optional(map(string), {})
      extra_headers             = optional(map(string), {})
    }), {})
    customization_public = optional(object({
      allow_snippet_annotations = optional(bool)
      http_snippet              = optional(string)
      extra_config              = optional(map(string))
      extra_headers             = optional(map(string))
    }), {})
    customization_private = optional(object({
      allow_snippet_annotations = optional(bool)
      http_snippet              = optional(string)
      extra_config              = optional(map(string))
      extra_headers             = optional(map(string))
    }), {})
  })
  default = {}
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
# tflint-ignore: terraform_unused_declarations
variable "node_ttl_enabled" {
  description = "Should Node TTL be enabled"
  type        = bool
  default     = true
}

variable "linkerd_enabled" {
  description = "Should linkerd be enabled"
  type        = bool
  default     = false
}

variable "control_plane_logs_enabled" {
  description = "Should Control plan be enabled"
  type        = bool
  default     = false
}

variable "kubernetes_network_policy_default_deny" {
  description = "If network policies should by default deny cross namespace traffic"
  type        = bool
  default     = true
}

variable "promtail_enabled" {
  description = "Should promtail be enabled"
  type        = bool
  default     = true
}

variable "promtail_included_tenant_namespaces" {
  description = "If network policies should by default deny cross namespace traffic"
  type        = list(string)
  default     = []
}

variable "public_ip_prefix_configuration" {
  description = "Configuration for public IP prefix"
  type = object({
    count         = number
    prefix_length = number
  })
  default = {
    count         = 2
    prefix_length = 30
  }
}

variable "external_dns_hostname" {
  description = "hostname for ingress-nginx to use for external-dns"
  type        = string
  default     = ""
}
# tflint-ignore: terraform_unused_declarations
variable "aks_name_suffix1" {
  description = "Suffix for the aks name"
  type        = number
  default     = 1
}
# tflint-ignore: terraform_unused_declarations
variable "aks_name_suffix2" {
  description = "Suffix for the aks name"
  type        = number
  default     = 2
}
# tflint-ignore: terraform_unused_declarations
variable "gatekeeper_enabled" {
  description = "Should OPA Gatekeeper be enabled"
  type        = bool
  default     = true
}
# tflint-ignore: terraform_unused_declarations
variable "acr_name_override" {
  description = "Override the ACR naming convention"
  type        = string
  default     = ""
}
