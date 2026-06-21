output "karpenter_role_arn" {
  description = "Karpenter IAM Role ARN"
  value       = aws_iam_role.karpenter.arn
}

output "karpenter_role_name" {
  description = "Karpenter IAM Role Name"
  value       = aws_iam_role.karpenter.name
}