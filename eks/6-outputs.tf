output "cluster_id" {
  description = "EKS Cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.main.name
}

output "cluster_version" {
  description = "EKS Cluster Version"
  value       = aws_eks_cluster.main.version
}

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "EKS Cluster managed Security Group ID"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_arn" {
  description = "EKS Cluster IAM Role ARN"
  value       = aws_iam_role.cluster.arn
}

output "node_group_id" {
  description = "EKS Node Group ID"
  value       = aws_eks_node_group.main.id
}

output "cluster_arn" {
  description = "EKS Cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_kms_key_arn" {
  description = "KMS key ARN used for EKS encryption — shared with bastion EBS"
  value       = aws_kms_key.eks.arn
}

output "cluster_ca_certificate" {
  description = "EKS cluster CA certificate (base64 encoded)"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}
