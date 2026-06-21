output "cluster_security_group_id" {
  description = "EKS Cluster Security Group ID"
  value       = aws_security_group.cluster.id
}

output "bastion_security_group_id" {
  description = "Bastion Host Security Group ID"
  value       = aws_security_group.bastion.id
}

output "node_security_group_id" {
  description = "EKS Node Security Group ID"
  value       = aws_security_group.node.id
}
