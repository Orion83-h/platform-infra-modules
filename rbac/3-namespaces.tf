 resource "kubernetes_namespace" "dev" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.key
    labels = {
      environment                      = var.environment
      "app.kubernetes.io/managed-by"   = "terraform"
    }
  }
}
