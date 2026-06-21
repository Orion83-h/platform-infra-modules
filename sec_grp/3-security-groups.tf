# EKS Cluster Security Group
resource "aws_security_group" "cluster" {
  name        = "${var.environment}-eks-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-eks-cluster-sg"
    }
  )
}

# Ingress rule to allow traffic from the bastion host to the EKS API server
resource "aws_security_group_rule" "cluster_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.cluster.id
}

# Allow bastion host to reach EKS API server on port 443
resource "aws_security_group_rule" "cluster_ingress_bastion_api" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  description              = "Allow bastion kubectl to reach EKS API server"
  security_group_id        = aws_security_group.cluster.id
}

# Allow all outbound traffic from the EKS cluster
resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
}

# Bastion Host Security Group
resource "aws_security_group" "bastion" {
  name        = "${var.environment}-bastion-sg"
  description = "Bastion host security group - SSM and EKS API egress only, no inbound"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    { Name = "${var.environment}-bastion-sg" }
  )
}

# SSM requires HTTPS to SSM, EC2Messages, and SSMMessages endpoints
resource "aws_security_group_rule" "bastion_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS for SSM endpoints, EKS API, and AWS APIs"
  security_group_id = aws_security_group.bastion.id
}

# Node Security Group
resource "aws_security_group" "node" {
  name        = "${var.environment}-eks-node-sg"
  description = "EKS node security group"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-eks-node-sg"
    }
  )
}

# Allow nodes to communicate with each other
resource "aws_security_group_rule" "node_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.node.id
}

# Allow the nodes to communicate with the EKS cluster
# (this is actually handled by the VPC CNI plugin)
resource "aws_security_group_rule" "node_ingress_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.node.id
}

# Allow all outbound traffic from the EKS nodes
resource "aws_security_group_rule" "node_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.node.id
}
