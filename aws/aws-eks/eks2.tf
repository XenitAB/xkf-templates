provider "kubernetes" {
  alias                  = "eks2"
  host                   = module.eks2.kube_config.host
  cluster_ca_certificate = module.eks2.kube_config.cluster_ca_certificate
  token                  = module.eks2.kube_config.token
}

provider "helm" {
  alias = "eks2"
  kubernetes {
    host                   = module.eks2.kube_config.host
    cluster_ca_certificate = module.eks2.kube_config.cluster_ca_certificate
    token                  = module.eks2.kube_config.token
  }
}

provider "kubectl" {
  alias                  = "eks2"
  host                   = module.eks2.kube_config.host
  cluster_ca_certificate = module.eks2.kube_config.cluster_ca_certificate
  token                  = module.eks2.kube_config.token
  load_config_file       = false
}

module "eks2" {
  source = "github.com/xenitab/terraform-modules//modules/aws/eks?ref=2de07c61ce0806fad23518627d4bc0128d875b44"

  providers = {
    aws           = aws
    aws.eks_admin = aws.eks_admin
  }

  environment         = var.environment
  name                = var.eks_name
  eks_name_suffix     = 2
  eks_config          = var.eks_config
  cluster_role_arn    = module.eks_global.cluster_role_arn
  node_group_role_arn = module.eks_global.node_group_role_arn
  aws_kms_key_arn     = module.eks_global.eks_encryption_key_arn
  velero_config       = module.eks_global.velero_config
  eks_authorized_ips  = var.eks_authorized_ips
  starboard_enabled   = true
}

module "eks2_core" {
  source = "github.com/xenitab/terraform-modules//modules/kubernetes/eks-core?ref=2de07c61ce0806fad23518627d4bc0128d875b44"

  providers = {
    kubernetes = kubernetes.eks2
    helm       = helm.eks2
    kubectl    = kubectl.eks2
  }

  environment       = var.environment
  name              = var.eks_name
  eks_name_suffix   = 2
  subscription_name = var.azure_subscription_name
  group_name_prefix = var.aks_group_name_prefix
  namespaces = [for n in var.tenant_namespaces :
    {
      name   = n.name
      labels = n.labels
      flux   = n.flux
    }
  ]

  kubernetes_network_policy_default_deny = true
  aad_groups                             = module.xkf_governance_global_data.aad_groups
  external_dns_config                    = module.eks2.external_dns_config

  fluxcd_v2_config = local.fluxcd_v2_config

  velero_config = module.eks2.velero_config
  cert_manager_config = {
    role_arn           = module.eks2.cert_manager_config.role_arn
    notification_email = "DG-Team-DevOps@xenit.se"
    dns_zone           = var.dns_zones
  }

  ingress_config                         = var.ingress_config
  cluster_autoscaler_config              = module.eks2.cluster_autoscaler_config
  opa_gatekeeper_enabled                 = true
  csi_secrets_store_provider_aws_enabled = true

  azad_kube_proxy_enabled = true
  azad_kube_proxy_config = {
    fqdn                  = "eks.${var.dns_zones[0]}"
    azure_ad_group_prefix = var.aks_group_name_prefix
    allowed_ips           = var.eks_authorized_ips
    azure_ad_app          = module.eks_global.azad_kube_proxy.azure_ad_app
  }

  falco_enabled = true

  prometheus_enabled = var.prometheus_enabled
  prometheus_config = {
    role_arn                        = module.eks2.prometheus_config.role_arn
    tenant_id                       = var.tenant_id
    remote_write_authenticated      = var.prometheus_config.remote_write_authenticated
    remote_write_url                = var.prometheus_config.remote_write_url
    volume_claim_storage_class_name = "gp2"
    volume_claim_size               = var.prometheus_config.volume_claim_size
    resource_selector               = var.prometheus_config.resource_selector
    namespace_selector              = var.prometheus_config.namespace_selector
  }

  datadog_enabled = local.datadog_enabled
  datadog_config  = local.datadog_config

  starboard_config  = module.eks2.starboard_config
  starboard_enabled = true

  promtail_enabled = var.promtail_enabled
  promtail_config = {
    role_arn            = module.eks2.promtail_config.role_arn
    loki_address        = "https://logging.prod.unbox.xenit.io/loki/api/v1/push"
    excluded_namespaces = var.tenant_namespaces[*].name
  }
}
