module "azpagent" {
  source            = "github.com/xenitab/terraform-modules//modules/azure/azure-pipelines-agent-vmss?ref=2023.08.2"
  environment       = var.environment
  location_short    = var.location_short
  unique_suffix     = var.unique_suffix
  name              = var.azpagent_name
  keyvault_name     = var.keyvault_name
  source_image_id   = var.azpagent_image_id
  vmss_sku          = var.azpagent_vmss_sku
  vmss_disk_size_gb = 64
  vmss_subnet_id    = module.hub.subnets["sn-${var.environment}-${var.location_short}-${local.name}-servers"].id
}
