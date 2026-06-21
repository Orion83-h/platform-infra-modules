data "aws_caller_identity" "current" {}

resource "aws_iam_role" "alb_controller" {
  name = "${var.environment}-aws-load-balancer-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = ["sts:AssumeRole", "sts:TagSession"]
      Principal = { Service = "pods.eks.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "alb_controller" {
  name = "${var.environment}-aws-load-balancer-controller-policy"
  role = aws_iam_role.alb_controller.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Describe-only actions have no resource-level support in elbv2
        Sid    = "ELBDescribe"
        Effect = "Allow"
        Action = [
          "elbv2:DescribeListenerCertificates",
          "elbv2:DescribeListeners",
          "elbv2:DescribeLoadBalancerAttributes",
          "elbv2:DescribeLoadBalancers",
          "elbv2:DescribeRules",
          "elbv2:DescribeSslPolicies",
          "elbv2:DescribeTags",
          "elbv2:DescribeTargetGroupAttributes",
          "elbv2:DescribeTargetGroups",
          "elbv2:DescribeTargetHealth"
        ]
        Resource = "*"
      },
      {
        Sid    = "ELBMutate"
        Effect = "Allow"
        Action = [
          "elbv2:AddListenerCertificates",
          "elbv2:AddTags",
          "elbv2:CreateListener",
          "elbv2:CreateRule",
          "elbv2:DeleteListener",
          "elbv2:DeleteRule",
          "elbv2:ModifyListener",
          "elbv2:ModifyRule",
          "elbv2:RemoveListenerCertificates",
          "elbv2:RemoveTags"
        ]
        Resource = "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.current.account_id}:listener/*"
      },
      {
        Sid    = "ELBLoadBalancerMutate"
        Effect = "Allow"
        Action = [
          "elbv2:CreateLoadBalancer",
          "elbv2:DeleteLoadBalancer",
          "elbv2:ModifyLoadBalancerAttributes",
          "elbv2:SetIpAddressType",
          "elbv2:SetSecurityGroups",
          "elbv2:SetSubnets"
        ]
        Resource = "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.current.account_id}:loadbalancer/*"
      },
      {
        Sid    = "ELBTargetGroupMutate"
        Effect = "Allow"
        Action = [
          "elbv2:CreateTargetGroup",
          "elbv2:DeleteTargetGroup",
          "elbv2:DeregisterTargets",
          "elbv2:ModifyTargetGroup",
          "elbv2:ModifyTargetGroupAttributes",
          "elbv2:RegisterTargets"
        ]
        Resource = "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.current.account_id}:targetgroup/*"
      },
      {
        # EC2 Describe/Get actions have no resource-level support
        Sid    = "EC2Describe"
        Effect = "Allow"
        Action = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstanceConnectEndpoints",
          "ec2:DescribeInstances",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeVpcs",
          "ec2:GetManagedPrefixListEntries"
        ]
        Resource = "*"
      },
      {
        Sid    = "EC2SecurityGroupMutate"
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateTags",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteTags",
          "ec2:RevokeSecurityGroupIngress"
        ]
        Resource = "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:security-group/*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = var.cluster_name
          }
        }
      },
      {
        Sid    = "EC2SecurityGroupCreate"
        Effect = "Allow"
        Action = ["ec2:CreateSecurityGroup"]
        Resource = "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:vpc/*"
      },
      {
        Sid    = "EC2NetworkInterfaceMutate"
        Effect = "Allow"
        Action = [
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifyNetworkInterfaceAttribute"
        ]
        Resource = [
          "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/*",
          "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:network-interface/*"
        ]
      },
      {
        # ACM, WAF, Shield, Cognito describe actions have no resource-level support
        Sid    = "CertWAFShieldDescribe"
        Effect = "Allow"
        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "cognito-idp:DescribeUserPoolClient",
          "shield:DescribeProtection",
          "shield:GetSubscriptionState",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMServerCertificate"
        Effect = "Allow"
        Action = [
          "iam:GetServerCertificate",
          "iam:ListServerCertificates"
        ]
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:server-certificate/*"
      },
      {
        # tag: actions have no resource-level support
        Sid    = "TagResources"
        Effect = "Allow"
        Action = [
          "tag:GetResources",
          "tag:TagResources"
        ]
        Resource = "*"
      },
      {
        # elasticloadbalancing Describe actions have no resource-level support
        Sid    = "ELBClassicDescribe"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_eks_pod_identity_association" "alb_controller" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.alb_controller.arn
}
