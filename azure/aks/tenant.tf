locals {

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

  # Configure grafana_agent_config to ship logs and metrics to Grafana Cloud with Grafana Agent
  grafana_agent_enabled = false
  grafana_agent_config = {
    remote_write_urls = {
      metrics = ""
      logs    = ""
      traces  = ""
    }
    credentials = {
      metrics_username = ""
      metrics_password = ""
      logs_username    = ""
      logs_password    = ""
      traces_username  = ""
      traces_password  = ""
    }
    extra_namespaces        = []
    include_kubelet_metrics = false
  }

  # Configure datadog_config to ship logs and metrics to Datadog
  datadog_enabled = false
  datadog_config = {
    datadog_site         = ""
    api_key              = ""
    app_key              = ""
    namespaces           = [""]
    apm_ignore_resources = []
  }

  ingress_config = {
    http_snippet              = ""
    public_private_enabled    = false
    allow_snippet_annotations = false
    extra_config              = {}
    extra_headers             = {}
  }
}
