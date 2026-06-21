# platform-infra-modules

A collection of reusable Terraform modules for provisioning and managing an EKS-based platform on AWS.

## Modules

| Module | Description |
|--------|-------------|
| `vpc` | VPC with public/private subnets, NAT gateways, and route tables |
| `sec_grp` | Security groups for EKS cluster, nodes, and bastion host |
| `eks` | EKS cluster with managed node group, KMS encryption, and CloudWatch logging |
| `bastion-host` | Bastion EC2 instance with EBS encryption and kubeconfig bootstrap |
| `aws-load-balancer-controller` | AWS Load Balancer Controller via EKS Pod Identity |
| `ebs-csi` | EBS CSI driver with KMS encryption via EKS Pod Identity |
| `cert-manager` | cert-manager with Route53 DNS-01 support via EKS Pod Identity |
| `karpenter` | Karpenter autoscaler via EKS Pod Identity |
| `velero` | Velero backup/restore with KMS-encrypted S3 via EKS Pod Identity |
| `helm` | ArgoCD and kube-prometheus-stack Helm releases |
| `rbac` | Kubernetes namespaces, roles, and IAM role bindings |

## Requirements

- Terraform `>= 1.0`
- AWS provider `~> 5.0`

## Usage

Each module is versioned independently using Git tags in the format `<module>-v<version>`.

Reference a module from a root configuration:

```hcl
module "vpc" {
  source = "git::https://github.com/<org>/platform-infra-modules.git//vpc?ref=vpc-v1.0.0"

  environment          = "prod"
  vpc_cidr             = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  eks_cluster_name     = "my-cluster"
}
```

## Versioning

Use the helper script to tag and push a new module version:

```bash
./scripts/tag-module.sh <module> <version> "<message>"

# Example
./scripts/tag-module.sh eks 1.2.0 
```

This creates and pushes a Git tag `eks-v1.2.0`. Update the `?ref=` in your root configuration accordingly.

## Module Reference

### `vpc`

| Variable | Type | Description |
|----------|------|-------------|
| `environment` | `string` | Environment name |
| `vpc_cidr` | `string` | CIDR block for the VPC |
| `private_subnet_cidrs` | `list(string)` | CIDRs for private subnets |
| `public_subnet_cidrs` | `list(string)` | CIDRs for public subnets |
| `availability_zones` | `list(string)` | Availability zones |
| `eks_cluster_name` | `string` | EKS cluster name (used for subnet tags) |
| `common_tags` | `map(string)` | Tags applied to all resources |

Outputs: `vpc_id`, `vpc_cidr`, `private_subnet_ids`, `public_subnet_ids`, `nat_gateway_ids`, `internet_gateway_id`

---

### `sec_grp`

| Variable | Type | Description |
|----------|------|-------------|
| `environment` | `string` | Environment name |
| `vpc_id` | `string` | VPC ID |
| `common_tags` | `map(string)` | Tags applied to all resources |

Outputs: `cluster_security_group_id`, `bastion_security_group_id`, `node_security_group_id`

---

### `eks`

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `environment` | `string` | | Environment name |
| `eks_cluster_name` | `string` | | EKS cluster name |
| `kubernetes_version` | `string` | `"1.34"` | Kubernetes version |
| `subnet_ids` | `list(string)` | | Subnet IDs for the cluster |
| `vpc_id` | `string` | | VPC ID |
| `cluster_security_group_id` | `string` | | Cluster security group ID |
| `desired_size` | `number` | `2` | Desired node count |
| `min_size` | `number` | `1` | Minimum node count |
| `max_size` | `number` | `5` | Maximum node count |
| `instance_types` | `list(string)` | `["t3.medium"]` | Node instance types |
| `endpoint_private_access` | `bool` | `true` | Enable private API endpoint |
| `endpoint_public_access` | `bool` | `false` | Enable public API endpoint |
| `addon_version_pod_identity` | `string` | | eks-pod-identity-agent add-on version |
| `addon_version_vpc_cni` | `string` | | vpc-cni add-on version |
| `addon_version_coredns` | `string` | | coredns add-on version |
| `addon_version_kube_proxy` | `string` | | kube-proxy add-on version |
| `common_tags` | `map(string)` | `{}` | Tags applied to all resources |

Outputs: `cluster_id`, `cluster_name`, `cluster_version`, `cluster_endpoint`, `cluster_arn`, `cluster_security_group_id`, `cluster_iam_role_arn`, `cluster_kms_key_arn`, `cluster_ca_certificate`, `node_group_id`

---

### `bastion-host`

| Variable | Type | Description |
|----------|------|-------------|
| `environment` | `string` | Environment name |
| `subnet_id` | `string` | Public subnet ID |
| `vpc_id` | `string` | VPC ID |
| `security_group_id` | `string` | Security group ID |
| `instance_type` | `string` | EC2 instance type |
| `eks_cluster_name` | `string` | Full cluster name for kubeconfig bootstrap |
| `eks_cluster_arn` | `string` | Cluster ARN for IAM least-privilege |
| `kms_key_arn` | `string` | KMS key ARN for EBS root volume encryption |
| `common_tags` | `map(string)` | Tags applied to all resources |

---

### `aws-load-balancer-controller`

| Variable | Type | Description |
|----------|------|-------------|
| `environment` | `string` | Environment name |
| `cluster_name` | `string` | EKS cluster name |
| `aws_region` | `string` | AWS region |
| `common_tags` | `map(string)` | Tags applied to all resources |

---

### `ebs-csi`

| Variable | Type | Description |
|----------|------|-------------|
| `environment` | `string` | Must be `dev`, `staging`, or `prod` |
| `cluster_name` | `string` | EKS cluster name |
| `common_tags` | `map(string)` | Tags applied to all resources |

---

### `cert-manager`

| Variable | Type | Description |
|----------|------|-------------|
| `environment` | `string` | Environment name |
| `cluster_name` | `string` | EKS cluster name |
| `common_tags` | `map(string)` | Tags applied to all resources |

---

### `karpenter`

| Variable | Type | Description |
|----------|------|-------------|
| `environment` | `string` | Environment name |
| `cluster_name` | `string` | EKS cluster name |
| `cluster_version` | `string` | EKS cluster version |
| `common_tags` | `map(string)` | Tags applied to all resources |

---

### `velero`

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `environment` | `string` | | Environment name |
| `cluster_name` | `string` | | EKS cluster name |
| `region` | `string` | `"us-east-1"` | AWS region |
| `velero_namespace` | `string` | `"velero"` | Namespace for Velero |
| `velero_service_account` | `string` | `"velero"` | Velero service account name |
| `common_tags` | `map(string)` | `{}` | Tags applied to all resources |

---

### `helm`

| Variable | Type | Description |
|----------|------|-------------|
| `environment` | `string` | Environment name |
| `cluster_name` | `string` | EKS cluster name |
| `argocd_chart_version` | `string` | ArgoCD Helm chart version |
| `prometheus_chart_version` | `string` | kube-prometheus-stack Helm chart version |
| `common_tags` | `map(string)` | Tags applied to all resources |

---

### `rbac`

| Variable | Type | Description |
|----------|------|-------------|
| `environment` | `string` | Environment name |
| `eks_cluster_name` | `string` | EKS cluster name |
| `cluster_endpoint` | `string` | EKS cluster endpoint |
| `cluster_ca_certificate` | `string` | EKS CA certificate (base64, sensitive) |
| `namespaces` | `list(string)` | Developer namespaces to create |
| `developer_role_arns` | `list(string)` | IAM role ARNs bound to the dev-edit ClusterRole |
| `common_tags` | `map(string)` | Tags applied to all resources |
