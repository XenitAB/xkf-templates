module "ghrunner" {
  source                   = "github.com/xenitab/terraform-modules//modules/azure/github-runner?ref=2023.08.2"
  environment              = var.environment
  location_short           = var.location_short
  name                     = "ghrunner"
  source_image_id          = var.ghrunner_image_id
  vmss_sku                 = var.ghrunner_vmss_sku
  vmss_instances           = var.ghrunner_vmss_instances
  vmss_disk_size_gb        = var.ghrunner_vmss_disk_size_gb
  vmss_zones               = var.ghrunner_vmss_zones
  vmss_diff_disk_placement = var.ghrunner_vmss_diff_disk_placement
  unique_suffix            = var.unique_suffix
  vmss_subnet_config = {
    name                 = module.hub.subnets["sn-${var.environment}-${var.location_short}-${local.name}-servers"].name
    virtual_network_name = module.hub.virtual_networks.name
    resource_group_name  = module.hub.resource_groups.name
  }
}
