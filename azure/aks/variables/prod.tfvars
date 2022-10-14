environment = "prod"
dns_zones   = []

aks_config = {
  version          = "1.23.8"
  production_grade = true
  node_pools = [
    {
      name           = "standard1"
      version        = "1.23.8"
      vm_size        = "Standard_D4ds_v5"
      min_count      = 2
      max_count      = 15
      node_labels    = {}
      node_taints    = []
      spot_enabled   = false
      spot_max_price = null
    },
  ]
}

