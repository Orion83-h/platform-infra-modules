#!/bin/bash
set -euo pipefail

# Install kubectl with checksum verification
KUBECTL_VERSION="v1.32.0"
KUBECTL_URL="https://dl.k8s.io/release/$${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
KUBECTL_SHA_URL="$${KUBECTL_URL}.sha256"

curl -fsSLo /tmp/kubectl "$${KUBECTL_URL}"
curl -fsSLo /tmp/kubectl.sha256 "$${KUBECTL_SHA_URL}"
echo "$(cat /tmp/kubectl.sha256)  /tmp/kubectl" | sha256sum --check --status
install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
rm -f /tmp/kubectl /tmp/kubectl.sha256

# Configure kubeconfig for all SSM sessions
cat > /etc/profile.d/eks.sh <<'PROFILE'
export AWS_DEFAULT_REGION=${aws_region}
aws eks update-kubeconfig --region ${aws_region} --name ${eks_cluster_name} --kubeconfig /root/.kube/config 2>/dev/null || true
PROFILE
chmod 644 /etc/profile.d/eks.sh
