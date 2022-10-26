environment = "dev"
dns_zones   = []

eks_config = {
  version    = "1.23"
  cidr_block = "10.100.0.0/18"
  node_pools = [
    {
      name           = "standard2"
      version        = "1.23.9-20220824"
      min_size       = 3
      max_size       = 6
      instance_types = ["t3.large"]
      node_labels    = {}
    },
  ]
}

eks_authorized_ips = []
