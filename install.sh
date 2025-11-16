#!/usr/bin/env bash

set -eu
# Note: pipefail is bash 4+ only, omitted for broader compatibility

# ACLI Installer Script
# Usage: curl -fsSL https://raw.githubusercontent.com/zero-to-prod/acli/main/install.sh | bash
# Usage with auto-yes: curl -fsSL https://raw.githubusercontent.com/zero-to-prod/acli/main/install.sh | bash -s -- -y
# Tested on: macOS 13+, Ubuntu 22.04+, Windows Git Bash, WSL2

# Configuration
DOCKER_IMAGE="davidsmith3/acli:latest"
CONFIG_DIR="${HOME}/.config/acli"
ALIAS_NAME="acli"
ALIAS_CMD="docker run -it --rm -v ~/.config/acli:/root/.config/acli -v \$(pwd):/workspace -w /workspace davidsmith3/acli"
AUTO_YES=false

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Linux*) echo "linux" ;;
        Darwin*) echo "macos" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

PLATFORM="$(detect_platform)"

# Detect terminal color support
setup_colors() {
    # Respect NO_COLOR environment variable (https://no-color.org/)
    if [ -n "${NO_COLOR:-}" ]; then
        RED=""
        GREEN=""
        NC=""
        return
    fi

    # Check if output is to a terminal
    if [ ! -t 1 ]; then
        RED=""
        GREEN=""
        NC=""
        return
    fi

    # Check terminal color support
    if command -v tput > /dev/null 2>&1 && tput colors > /dev/null 2>&1; then
        local colors
        colors="$(tput colors 2>/dev/null || echo 0)"
        if [ "$colors" -ge 8 ]; then
            RED='\033[0;31m'
            GREEN='\033[0;32m'
            NC='\033[0m'
        else
            RED=""
            GREEN=""
            NC=""
        fi
    else
        # Fallback: check TERM variable
        case "${TERM:-dumb}" in
            *color*|xterm*|screen*|tmux*)
                RED='\033[0;31m'
                GREEN='\033[0;32m'
                NC='\033[0m'
                ;;
            *)
                RED=""
                GREEN=""
                NC=""
                ;;
        esac
    fi
}

setup_colors

error() { echo -e "${RED}✗${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }

# Parse arguments
while [ $# -gt 0 ]; do
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
    if [ "${AUTO_YES}" = true ]; then
        return 0
    fi
    echo -n "$1"
    read -r response
    # POSIX-compliant pattern matching
    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

detect_shell() {
    local shell_name
    shell_name="$(basename "${SHELL:-bash}")"

    case "$shell_name" in
        bash)
            # macOS prefers .bash_profile for login shells
            if [ "$PLATFORM" = "macos" ]; then
                if [ -f "${HOME}/.bash_profile" ]; then
                    echo "${HOME}/.bash_profile"
                elif [ -f "${HOME}/.bashrc" ]; then
                    echo "${HOME}/.bashrc"
                else
                    echo "${HOME}/.bash_profile"
                fi
            else
                # Linux/Windows prefer .bashrc
                if [ -f "${HOME}/.bashrc" ]; then
                    echo "${HOME}/.bashrc"
                elif [ -f "${HOME}/.bash_profile" ]; then
                    echo "${HOME}/.bash_profile"
                else
                    echo "${HOME}/.bashrc"
                fi
            fi
            ;;
        zsh) echo "${HOME}/.zshrc" ;;
        fish) echo "${HOME}/.config/fish/config.fish" ;;
        ksh|ksh93) echo "${HOME}/.kshrc" ;;
        *) echo "${HOME}/.profile" ;;
    esac
}

# Check Docker
if ! command -v docker > /dev/null 2>&1; then
    error "Docker is not installed."
    echo ""
    echo "Please install Docker first:"
    case "$PLATFORM" in
        macos)
            echo "  macOS: https://docs.docker.com/desktop/install/mac-install/"
            ;;
        linux)
            echo "  Linux: https://docs.docker.com/engine/install/"
            ;;
        windows)
            echo "  Windows: https://docs.docker.com/desktop/install/windows-install/"
            ;;
        *)
            echo "  https://docs.docker.com/get-docker/"
            ;;
    esac
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    error "Docker daemon is not running."
    echo ""
    case "$PLATFORM" in
        macos)
            echo "Start Docker Desktop from your Applications folder"
            ;;
        linux)
            echo "Start Docker with: sudo systemctl start docker"
            echo "Or: sudo service docker start"
            ;;
        windows)
            echo "Start Docker Desktop from the Windows Start menu"
            ;;
        *)
            echo "Please start Docker and try again."
            ;;
    esac
    exit 1
fi

# Pull image
docker pull "${DOCKER_IMAGE}" || { error "Failed to pull Docker image"; exit 1; }

# Create config directory
if [ ! -d "${CONFIG_DIR}" ]; then
    mkdir -p "${CONFIG_DIR}"
    chmod 700 "${CONFIG_DIR}"
fi

# Authentication
shell_config="$(detect_shell)"
shell_name="$(basename "${SHELL:-bash}")"

if [ "${AUTO_YES}" = true ]; then
    echo ""
    echo "To authenticate, run:"
    echo -e "  ${GREEN}docker run -it --rm -v ~/.config/acli:/root/.config/acli ${DOCKER_IMAGE} jira auth login${NC}"
    echo ""
    echo "Or with the alias (after adding it to your shell):"
    echo -e "  ${GREEN}${ALIAS_NAME} jira auth login${NC}"
    echo ""
    echo "You'll need an API token from: https://id.atlassian.com/manage-profile/security/api-tokens"
elif prompt_user "Would you like to configure authentication now? (y/N) "; then
    echo ""
    echo "Get your API token from: https://id.atlassian.com/manage-profile/security/api-tokens"
    echo ""
    docker run -it --rm -v "${CONFIG_DIR}:/root/.config/acli" "${DOCKER_IMAGE}" jira auth login
else
    echo ""
    echo "To authenticate later, run:"
    echo -e "  ${GREEN}docker run -it --rm -v ~/.config/acli:/root/.config/acli ${DOCKER_IMAGE} jira auth login${NC}"
    echo ""
    echo "Or with the alias (after adding it to your shell):"
    echo -e "  ${GREEN}${ALIAS_NAME} jira auth login${NC}"
    echo ""
    echo "You'll need an API token from: https://id.atlassian.com/manage-profile/security/api-tokens"
fi

# Success message
echo ""
echo "Documentation:"
echo "  - Project: https://github.com/zero-to-prod/acli"
echo "  - ACLI Docs: https://developer.atlassian.com/cloud/acli/"
echo ""
echo "Example commands:"
echo -e "  ${GREEN}${ALIAS_NAME} jira workitem view PROJ-123${NC}"
echo -e "  ${GREEN}${ALIAS_NAME} jira workitem search --jql \"project = MY-PROJECT\"${NC}"
echo ""
echo "To add a convenient alias, add this line to ${shell_config}:"
echo ""
if [ "${shell_name}" = "fish" ]; then
    echo -e "  ${GREEN}alias ${ALIAS_NAME} 'docker run -it --rm -v ~/.config/acli:/root/.config/acli -v (pwd):/workspace -w /workspace davidsmith3/acli'${NC}"
else
    echo -e "  ${GREEN}alias ${ALIAS_NAME}='${ALIAS_CMD}'${NC}"
fi
echo ""