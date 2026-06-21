output "argocd_namespace" {
  description = "Namespace where ArgoCD is deployed"
  value       = helm_release.argocd.namespace
}