locals {

  eks_admin_assume_principal_ids = [""]

  # Configure fluxcd_v2_config for either Azure Devops or Github in order to set up Gitops with FluxCD
  # Below is an empty Github example
  fluxcd_v2_config = {
    type = "github"
    github = {
      org             = ""
      app_id          = 0
      installation_id = 0
      private_key     = ""
    }
    azure_devops = {
      pat  = ""
      org  = ""
      proj = ""
    }
  }

  # Configure datadog_config to ship logs and metrics to Datadog
  datadog_enabled = false
  datadog_config = {
    datadog_site         = ""
    role_arn             = module.eks2.datadog_config.role_arn
    namespaces           = [""]
    apm_ignore_resources = ["''"]
  }
}
