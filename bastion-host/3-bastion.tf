data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_region" "current" {}

# Bastion Host IAM Role
resource "aws_iam_role" "bastion" {
  name = "${var.environment}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion.name
}

resource "aws_iam_role_policy" "bastion_eks" {
  name = "${var.environment}-bastion-eks-policy"
  role = aws_iam_role.bastion.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EKSDescribe"
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = var.eks_cluster_arn
      },
      {
        Sid    = "EBSKMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.environment}-bastion-profile"
  role = aws_iam_role.bastion.name
}

# Bastion EC2 Instance
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu_2404.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = false
  monitoring                  = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 only
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    kms_key_id  = var.kms_key_arn
    volume_type = "gp3"
  }

  user_data = base64encode(templatefile("${path.module}/scripts/user_data.sh", {
    aws_region       = data.aws_region.current.name
    eks_cluster_name = var.eks_cluster_name
  }))

  tags = merge(
    var.common_tags,
    { Name = "${var.environment}-bastion-host" }
  )
}

output "bastion_instance_id" {
  description = "Bastion host instance ID"
  value       = aws_instance.bastion.id
}

output "bastion_private_ip" {
  description = "Bastion host private IP"
  value       = aws_instance.bastion.private_ip
}

output "bastion_role_arn" {
  description = "Bastion IAM role ARN"
  value       = aws_iam_role.bastion.arn
}

# EKS Access Entry — lives here to avoid circular Terragrunt dependency
# Bastion depends on EKS (cluster ARN, KMS); EKS does not depend on bastion
resource "aws_eks_access_entry" "bastion" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.bastion.arn
  type          = "STANDARD"

  tags = var.common_tags
}

resource "aws_eks_access_policy_association" "bastion" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.bastion.arn
  policy_arn    = "arn:aws:iam::aws:policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.bastion]
}
