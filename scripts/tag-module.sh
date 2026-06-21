#!/usr/bin/env bash
# Usage: ./scripts/tag-module.sh <module> <version> <message>
# Example: ./scripts/tag-module.sh eks 1.2.0 "Add IRSA support for Karpenter"

set -euo pipefail

MODULE="${1:?Usage: tag-module.sh <module> <version> <message>}"
VERSION="${2:?}"
MESSAGE="${3:?}"
TAG="${MODULE}-v${VERSION}"

echo "Tagging ${TAG}: ${MESSAGE}"
git tag -a "${TAG}" -m "${MESSAGE}"
git push origin "${TAG}"
echo "Done. Update root.hcl: ${MODULE} = \"${TAG}\""
