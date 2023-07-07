data "tls_certificate" "e6data_oidc_tls" {
  url = data.aws_eks_cluster.current.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "e6data_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.e6data_oidc_tls.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.current.identity[0].oidc[0].issuer
}
