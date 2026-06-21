variable "environment" {
  description = "Environment name"
  type        = string
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "EKS cluster CA certificate (base64 encoded)"
  type        = string
  sensitive   = true
}

variable "developer_role_arns" {
  description = "List of IAM role ARNs to bind to dev-edit ClusterRole"
  type        = list(string)
  default     = []
}

variable "namespaces" {
  description = "Developer namespaces to create and bind RBAC"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
