output "namespaces" {
  description = "Developer namespaces created"
  value       = [for ns in kubernetes_namespace.dev : ns.metadata[0].name]
}

output "dev_edit_role_name" {
  description = "ClusterRole name for developer edit access"
  value       = kubernetes_cluster_role.dev_edit.metadata[0].name
}
