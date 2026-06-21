output "ebs_csi_role_arn" {
  description = "EBS CSI Driver IAM Role ARN"
  value       = aws_iam_role.ebs_csi.arn
}

output "ebs_csi_role_name" {
  description = "EBS CSI Driver IAM Role Name"
  value       = aws_iam_role.ebs_csi.name
}

output "ebs_kms_key_arn" {
  description = "KMS key ARN for EBS volume encryption"
  value       = aws_kms_key.ebs.arn
}

output "ebs_kms_key_id" {
  description = "KMS key ID for EBS volume encryption"
  value       = aws_kms_key.ebs.key_id
}