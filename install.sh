#!/usr/bin/env bash

set -euo pipefail

# ACLI Installer Script
# Usage: curl -fsSL https://raw.githubusercontent.com/zero-to-prod/acli/main/install.sh | bash
# Usage with auto-yes: curl -fsSL https://raw.githubusercontent.com/zero-to-prod/acli/main/install.sh | bash -s -- -y

# Configuration
DOCKER_IMAGE="davidsmith3/acli:latest"
CONFIG_DIR="${HOME}/.config/acli"
ALIAS_NAME="acli"
ALIAS_CMD="docker run -it --rm -v ~/.config/acli:/root/.config/acli -v \$(pwd):/workspace -w /workspace davidsmith3/acli"
AUTO_YES=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

error() { echo "${RED}✗${NC} $1"; }
success() { echo "${GREEN}✓${NC} $1"; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes) AUTO_YES=true; shift ;;
        -h|--help)
            echo "ACLI Installer"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -y, --yes    Auto-approve all prompts"
            echo "  -h, --help   Show this help"
            echo ""
            echo "Examples:"
            echo "  curl -fsSL https://raw.githubusercontent.com/zero-to-prod/acli/main/install.sh | bash"
            echo "  curl -fsSL https://raw.githubusercontent.com/zero-to-prod/acli/main/install.sh | bash -s -- -y"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

prompt_user() {
    [ "${AUTO_YES}" = true ] && return 0
    echo "$1 "
    read -r response
    [[ "$response" =~ ^[yY]([eE][sS])?$ ]]
}

detect_shell() {
    case "$(basename "${SHELL}")" in
        bash)
            [ -f "${HOME}/.bashrc" ] && echo "${HOME}/.bashrc" || \
            [ -f "${HOME}/.bash_profile" ] && echo "${HOME}/.bash_profile" || \
            echo "${HOME}/.bashrc"
            ;;
        zsh) echo "${HOME}/.zshrc" ;;
        fish) echo "${HOME}/.config/fish/config.fish" ;;
        *) echo "${HOME}/.profile" ;;
    esac
}

# Check Docker
if ! command -v docker &> /dev/null; then
    error "Docker is not installed."
    echo ""
    echo "Please install Docker first:"
    echo "  - macOS/Windows: https://www.docker.com/products/docker-desktop"
    echo "  - Linux: https://docs.docker.com/engine/install/"
    exit 1
fi

if ! docker info &> /dev/null; then
    error "Docker daemon is not running."
    echo ""
    echo "Please start Docker and try again."
    exit 1
fi

# Pull image
docker pull "${DOCKER_IMAGE}" || { error "Failed to pull Docker image"; exit 1; }

# Create config directory
[ ! -d "${CONFIG_DIR}" ] && mkdir -p "${CONFIG_DIR}" && chmod 700 "${CONFIG_DIR}"

# Add alias
shell_config="$(detect_shell)"
shell_name="$(basename "${SHELL}")"

if [ -f "${shell_config}" ] && grep -q "alias ${ALIAS_NAME}=" "${shell_config}"; then
    :  # Alias already exists, do nothing
elif prompt_user "Add alias to ${shell_config}? (y/N)"; then
    if [ "${shell_name}" = "fish" ]; then
        {
            echo ""
            echo "# ACLI - Atlassian CLI Docker wrapper"
            echo "alias ${ALIAS_NAME} 'docker run -it --rm -v ~/.config/acli:/root/.config/acli -v (pwd):/workspace -w /workspace davidsmith3/acli'"
        } >> "${shell_config}"
    else
        {
            echo ""
            echo "# ACLI - Atlassian CLI Docker wrapper"
            echo "alias ${ALIAS_NAME}='${ALIAS_CMD}'"
        } >> "${shell_config}"
    fi
else
    echo ""
    echo "To manually add the alias, add this line to ${shell_config}:"
    [ "${shell_name}" = "fish" ] && \
        echo "  alias ${ALIAS_NAME} 'docker run -it --rm -v ~/.config/acli:/root/.config/acli -v (pwd):/workspace -w /workspace davidsmith3/acli'" || \
        echo "  alias ${ALIAS_NAME}='${ALIAS_CMD}'"
fi

# Authentication
if [ "${AUTO_YES}" = true ]; then
    echo ""
    echo "To authenticate, run:"
    echo "  ${GREEN}docker run -it --rm -v ~/.config/acli:/root/.config/acli ${DOCKER_IMAGE} jira auth login${NC}"
    echo ""
    echo "Or with the alias (after reloading your shell):"
    echo "  ${GREEN}${ALIAS_NAME} jira auth login${NC}"
    echo ""
    echo "You'll need an API token from: https://id.atlassian.com/manage-profile/security/api-tokens"
elif prompt_user "Would you like to configure authentication now? (y/N)"; then
    echo ""
    echo "Get your API token from: https://id.atlassian.com/manage-profile/security/api-tokens"
    echo ""
    docker run -it --rm -v "${CONFIG_DIR}:/root/.config/acli" "${DOCKER_IMAGE}" jira auth login
else
    echo ""
    echo "To authenticate later, run:"
    echo "  ${GREEN}docker run -it --rm -v ~/.config/acli:/root/.config/acli ${DOCKER_IMAGE} jira auth login${NC}"
    echo ""
    echo "Or with the alias (after reloading your shell):"
    echo "  ${GREEN}${ALIAS_NAME} jira auth login${NC}"
    echo ""
    echo "You'll need an API token from: https://id.atlassian.com/manage-profile/security/api-tokens"
fi

# Success message
echo ""
echo "To start using ACLI, either:"
echo ""
echo "  1. Reload your shell configuration:"
echo "     ${GREEN}source ${shell_config}${NC}"
echo ""
echo "  2. Open a new terminal window"
echo ""
echo "Then run:"
echo "  ${GREEN}${ALIAS_NAME} --help${NC}"
echo ""
echo "Example commands:"
echo "  ${GREEN}${ALIAS_NAME} jira workitem view PROJ-123${NC}"
echo "  ${GREEN}${ALIAS_NAME} jira workitem search --jql \"project = MY-PROJECT\"${NC}"
echo ""
echo "Documentation:"
echo "  - Project: https://github.com/zero-to-prod/acli"
echo "  - ACLI Docs: https://developer.atlassian.com/cloud/acli/"
echo ""