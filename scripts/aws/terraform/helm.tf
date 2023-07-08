resource "helm_release" "e6data_workspace_deployment" {
  provider = helm.eks_e6data

  name       = var.workspace_name
  repository = "https://e6x-labs.github.io/e6data-workspace/"
  chart = "workspace"
  namespace  = var.kubernetes_namespace
  create_namespace = true
  version    = var.helm_chart_version
  timeout = 600

  values = [local.helm_values_file]
}

data "kubernetes_config_map_v1" "aws_auth_read" {
  provider = kubernetes.eks_e6data

  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }
}

resource "kubernetes_config_map_v1" "aws_auth_update" {
  provider = kubernetes.eks_e6data
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = replace(yamlencode(local.totalRoles), "\"", "")
    mapUsers = replace(yamlencode(local.mapUsers), "\"", "")
    mapAccounts = replace(yamlencode(local.mapAccounts), "\"", "")
  }
}