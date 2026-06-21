output "alb_controller_role_arn" {
  description = "AWS Load Balancer Controller IAM Role ARN"
  value       = aws_iam_role.alb_controller.arn
}

output "alb_controller_role_name" {
  description = "AWS Load Balancer Controller IAM Role Name"
  value       = aws_iam_role.alb_controller.name
}
