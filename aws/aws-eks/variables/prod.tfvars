environment = "prod"

dns_zones = ["prod.winningtemp.com", "api.winningtemp.com"]

eks_config = {
  version    = "1.23"
  cidr_block = "10.100.128.0/18"
  node_pools = [
    {
      name           = "standard1"
      version        = "1.23.9-20220824"
      min_size       = 3
      max_size       = 8
      instance_types = ["r6i.xlarge"]
      node_labels    = {}
    },
  ]
}

eks_authorized_ips = []
