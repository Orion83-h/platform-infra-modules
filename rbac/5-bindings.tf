locals {
  # Cartesian product of namespaces x developer_role_arns for per-namespace bindings
  namespace_role_bindings = {
    for pair in flatten([
      for ns in var.namespaces : [
        for arn in var.developer_role_arns : {
          key       = "${ns}:${arn}"
          namespace = ns
          role_arn  = arn
        }
      ]
    ]) : pair.key => pair
  }
}

# Developer namespace edit permissions
resource "kubernetes_role_binding" "dev_edit" {
  for_each = local.namespace_role_bindings

  metadata {
    name      = "dev-edit-binding"
    namespace = each.value.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.dev_edit.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = each.value.role_arn
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [kubernetes_namespace.dev]
}
