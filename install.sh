#!/usr/bin/env bash

set -eu

# Usage: curl -fsSL https://raw.githubusercontent.com/zero-to-prod/acli/main/install.sh | bash

DOCKER_IMAGE="davidsmith3/acli:latest"
CONFIG_DIR="${HOME}/.config/acli"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

error() { echo -e "${RED}✗${NC} $1"; }

if ! command -v docker > /dev/null 2>&1; then
    error "Docker is not installed."
    echo ""
    echo "Install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    error "Docker daemon is not running."
    echo ""
    echo "Please start Docker and try again."
    exit 1
fi

echo "Pulling Docker image..."
docker pull "${DOCKER_IMAGE}" || { error "Failed to pull Docker image"; exit 1; }

mkdir -p "${CONFIG_DIR}"
chmod 700 "${CONFIG_DIR}"

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo ""
echo "1. Authenticate with Atlassian:"
echo "   Get API token: https://id.atlassian.com/manage-profile/security/api-tokens"
echo ""
echo "   Then run:"
echo -e "   ${GREEN}docker run -it --rm -v ~/.config/acli:/root/.config/acli ${DOCKER_IMAGE} jira auth login${NC}"
echo ""
echo "2. Add alias to your shell:"
echo -e "   ${GREEN}alias acli='docker run -it --rm -v ~/.config/acli:/root/.config/acli -v \$(pwd):/workspace -w /workspace ${DOCKER_IMAGE}'${NC}"
echo ""
echo "3. Documentation:"
echo "   - GitHub: https://github.com/zero-to-prod/acli"
echo "   - ACLI Docs: https://developer.atlassian.com/cloud/acli/"
echo ""