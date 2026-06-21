variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "velero_namespace" {
  description = "Kubernetes namespace where Velero is deployed"
  type        = string
  default     = "velero"
}

variable "velero_service_account" {
  description = "Kubernetes service account name for Velero"
  type        = string
  default     = "velero"
}
