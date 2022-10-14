environment = "dev"
vnet_config = {
  address_space = ["10.180.0.0/16"]
  dns_servers   = []
  subnets = [
    {
      name              = "servers"
      cidr              = "10.180.0.0/24"
      service_endpoints = []
      aks_subnet        = false
    },
    {
      name              = "aks1"
      cidr              = "10.180.1.0/24"
      service_endpoints = ["Microsoft.Storage"]
      aks_subnet        = true
    },
    {
      name              = "aks2"
      cidr              = "10.180.2.0/24"
      service_endpoints = ["Microsoft.Storage"]
      aks_subnet        = true
    },
  ]
}

peering_config = [
  {
    name                         = "hub"
    remote_virtual_network_id    = ""
    allow_forwarded_traffic      = true
    use_remote_gateways          = false
    allow_virtual_network_access = true
  },
]
