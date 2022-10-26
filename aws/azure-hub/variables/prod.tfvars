environment = "prod"

vnet_config = {
  address_space = ["10.100.192.0/22"]
  subnets = [
    {
      name              = "servers"
      cidr              = "10.100.192.0/24"
      service_endpoints = ["Microsoft.Storage"]
    },
  ]
}

peering_config = []
