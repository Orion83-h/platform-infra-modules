output "velero_bucket_name" {
  description = "Velero S3 bucket name"
  value       = aws_s3_bucket.velero.id
}

output "velero_role_arn" {
  description = "Velero IAM Role ARN"
  value       = aws_iam_role.velero.arn
}

output "velero_role_name" {
  description = "Velero IAM Role Name"
  value       = aws_iam_role.velero.name
}

output "velero_kms_key_arn" {
  description = "Velero S3 KMS Key ARN"
  value       = aws_kms_key.velero.arn
}