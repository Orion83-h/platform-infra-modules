# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.environment}-${var.eks_cluster_name}"
  version  = var.kubernetes_version
  role_arn = aws_iam_role.cluster.arn
  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [var.cluster_security_group_id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController
  ]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-${var.eks_cluster_name}"
    }
  )
}

# KMS Key for EKS encryption
resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS cluster encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-eks-key"
    }
  )
}

# KMS Alias for EKS encryption
resource "aws_kms_alias" "eks" {
  name          = "alias/${var.environment}-eks"
  target_key_id = aws_kms_key.eks.key_id
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${aws_eks_cluster.main.name}/cluster"
  retention_in_days = 7
  kms_key_id        = aws_kms_key.eks.arn

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-eks-logs"
    }
  )
}
