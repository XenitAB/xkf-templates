module "ghrunner" {
  source                   = "github.com/xenitab/terraform-modules//modules/azure/github-runner?ref=2022.08.1"
  environment              = var.environment
  location_short           = var.location_short
  name                     = "ghrunner"
  github_runner_image_name = "github-runner-2021-11-03T12-49-46Z"
  vmss_sku                 = "Standard_D2s_v3"
  vmss_instances           = 2
  vmss_disk_size_gb        = 50
  unique_suffix            = var.unique_suffix
  vmss_subnet_config = {
    name                 = module.hub.subnets["sn-${var.environment}-${var.location_short}-${var.name}-servers"].name
    virtual_network_name = module.hub.virtual_networks.name
    resource_group_name  = module.hub.resource_groups.name
  }
}
