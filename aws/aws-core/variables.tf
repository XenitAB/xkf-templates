variable "aws_location" {
  description = "The name of the location"
  type        = string
}

variable "core_name" {
  description = "The name of the core infra"
  type        = string
  default     = "core"
}

variable "cidr_block" {
  description = "CIDR block of the VPC. The prefix lenght of the CIDR block must be 18 or less"
  type        = string
}

variable "environment" {
  description = "The environment name to use for the deploy"
  type        = string
}

variable "dns_zones" {
  description = "The DNS Zone host name"
  type        = list(string)
}

variable "flow_log_enabled" {
  description = "Should flow log be enabled"
  type        = bool
  default     = false
}
variable "vpc_peering_config_requester" {
  description = "VPC Peering configuration"
  type = list(object({
    name                   = string
    peer_owner_id          = string
    peer_vpc_id            = string
    destination_cidr_block = string
  }))
  default = []
}
