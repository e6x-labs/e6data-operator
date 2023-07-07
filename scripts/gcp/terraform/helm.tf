resource "helm_release" "grafana_deployment" {
  provider = helm.gke_e6data

  name       = var.workspace_name
  repository = "https://e6x-labs.github.io/e6data-workspace/"
  chart = "workspace"
  namespace  = var.kubernetes_namespace
  version    = var.helm_chart_version
  timeout = 600

  set {
    name = "cloud.type"
    value = "GCP"
  }

  set {
    name = "cloud.oidc_value"
    value = google_service_account.workspace_sa.email
  }

  set {
    name = "cloud.control_plane_user"
    value = "{var.control_plane_user}"
  }
}