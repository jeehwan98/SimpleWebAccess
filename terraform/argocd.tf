# Install ArgoCD on EKS via Helm
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.3.3"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  # Disable HTTPS redirect — nginx-proxy terminates HTTP and proxies internally
  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }

  depends_on = [aws_eks_node_group.a]
}

# After terraform apply, bootstrap ArgoCD apps by running:
#   kubectl apply -f argocd/apps/
