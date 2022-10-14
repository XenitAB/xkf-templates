environment = "prod"

vnet_config = {
  address_space = ["10.179.0.0/16"]
  subnets = [
    {
      name              = "servers"
      cidr              = "10.179.0.0/24"
      service_endpoints = ["Microsoft.Storage"]
    },
  ]
}

peering_config = [
  {
    name                         = "core-dev"
    remote_virtual_network_id    = ""
    allow_forwarded_traffic      = true
    use_remote_gateways          = false
    allow_virtual_network_access = true
  },
  {
    name                         = "core-qa"
    remote_virtual_network_id    = ""
    allow_forwarded_traffic      = true
    use_remote_gateways          = false
    allow_virtual_network_access = true
  },
  {
    name                         = "core-prod"
    remote_virtual_network_id    = ""
    allow_forwarded_traffic      = true
    use_remote_gateways          = false
    allow_virtual_network_access = true
  },
]
