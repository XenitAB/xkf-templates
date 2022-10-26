azure_location          = "West Europe"
azure_location_short    = "we"
azure_subscription_name = "xks"
aws_location            = "eu-west-1"
unique_suffix           = "5667"
azure_ad_group_prefix   = "az"
aks_group_name_prefix   = "aks"
tenant_id               = "winningtemp"

tenant_namespaces = [
  {
    name                    = "wt"
    delegate_resource_group = true
    labels = {
      "terraform" = "true"
    }
    flux = {
      enabled     = true
      create_crds = false
      azure_devops = {
        org  = "Winningtemp"
        proj = "winningtemp"
        repo = "gitops"
      }
      github = {
        repo = ""
      }
    }
  },
]
