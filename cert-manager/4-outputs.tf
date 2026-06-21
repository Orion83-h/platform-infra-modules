output "cert_manager_role_arn" {
  description = "Cert-Manager IAM Role ARN"
  value       = aws_iam_role.cert_manager.arn
}

output "cert_manager_role_name" {
  description = "Cert-Manager IAM Role Name"
  value       = aws_iam_role.cert_manager.name
}