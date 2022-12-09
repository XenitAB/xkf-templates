module "ghrunner" {
  source            = "github.com/xenitab/terraform-modules//modules/azure/github-runner?ref=2022.12.3"
  environment       = var.environment
  location_short    = var.location_short
  name              = "ghrunner"
  source_image_id   = var.ghrunner_image_id
  vmss_sku          = var.ghrunner_vmss_sku
  vmss_instances    = 2
  vmss_disk_size_gb = 50
  unique_suffix     = var.unique_suffix
  vmss_subnet_config = {
    name                 = module.hub.subnets["sn-${var.environment}-${var.location_short}-${local.name}-servers"].name
    virtual_network_name = module.hub.virtual_networks.name
    resource_group_name  = module.hub.resource_groups.name
  }
}
