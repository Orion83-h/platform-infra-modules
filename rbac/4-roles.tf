resource "kubernetes_cluster_role" "dev_edit" {
  metadata {
    name = "dev-edit"
  }

  # Workload management
  rule {
    api_groups = ["", "apps", "batch", "autoscaling"]
    resources  = ["pods", "deployments", "replicasets", "statefulsets", "daemonsets", "jobs", "cronjobs", "services", "endpoints", "configmaps", "persistentvolumeclaims", "serviceaccounts", "horizontalpodautoscalers"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  # Logs and exec scoped to developer namespaces only (enforced via RoleBinding scope)
  rule {
    api_groups = [""]
    resources  = ["pods/log", "pods/portforward", "pods/exec"]
    verbs      = ["get", "list", "create"]
  }

  # Namespace-scoped RBAC management — devs can manage roles within their namespace
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  # Read-only on events for debugging
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["get", "list", "watch"]
  }

  # Explicitly no access to: secrets, resourcequotas, limitranges, clusterroles, clusterrolebindings
}

# EKS Access Entry per developer IAM role
resource "aws_eks_access_entry" "developers" {
  for_each = toset(var.developer_role_arns)

  cluster_name  = var.eks_cluster_name
  principal_arn = each.value
  type          = "STANDARD"

  tags = var.common_tags
}
