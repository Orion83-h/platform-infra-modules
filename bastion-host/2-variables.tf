variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the bastion host"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the bastion host"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "instance_type" {
  description = "Instance type for the bastion host"
  type        = string
}

variable "eks_cluster_name" {
  description = "Full EKS cluster name (environment-prefixed) for IAM and kubeconfig"
  type        = string
}

variable "eks_cluster_arn" {
  description = "EKS cluster ARN scoped for IAM least-privilege"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN used to encrypt the bastion EBS root volume"
  type        = string
}