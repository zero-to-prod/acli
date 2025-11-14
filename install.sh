#!/bin/bash
# ACLI Installation Script
# Installs the ACLI wrapper script or shell function

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
WRAPPER_URL="https://raw.githubusercontent.com/zero-to-prod/acli/main/acli.sh"
WRAPPER_NAME="acli"

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first:"
        echo "  https://docs.docker.com/get-docker/"
        exit 1
    fi

    if ! docker info > /dev/null 2>&1; then
        print_warn "Docker is installed but not running. Please start Docker."
        exit 1
    fi

    print_success "Docker is installed and running"
}

# Install wrapper script method
install_wrapper() {
    print_info "Installing ACLI wrapper script to ${INSTALL_DIR}/${WRAPPER_NAME}..."

    if [[ ! -w "${INSTALL_DIR}" ]]; then
        print_info "Requesting sudo access to write to ${INSTALL_DIR}..."
        sudo curl -fsSL "${WRAPPER_URL}" -o "${INSTALL_DIR}/${WRAPPER_NAME}"
        sudo chmod +x "${INSTALL_DIR}/${WRAPPER_NAME}"
    else
        curl -fsSL "${WRAPPER_URL}" -o "${INSTALL_DIR}/${WRAPPER_NAME}"
        chmod +x "${INSTALL_DIR}/${WRAPPER_NAME}"
    fi

    print_success "ACLI wrapper installed successfully!"
    print_info "You can now use: ${WRAPPER_NAME} --help"
}

# Install shell function method
install_function() {
    local shell_rc

    # Detect shell
    case "${SHELL}" in
        */bash)
            shell_rc="${HOME}/.bashrc"
            ;;
        */zsh)
            shell_rc="${HOME}/.zshrc"
            ;;
        *)
            print_error "Unsupported shell: ${SHELL}"
            print_info "Please manually add the function to your shell configuration"
            return 1
            ;;
    esac

    print_info "Installing ACLI shell function to ${shell_rc}..."

    # Check if function already exists
    if grep -q "# ACLI Docker Wrapper" "${shell_rc}" 2>/dev/null; then
        print_warn "ACLI function already exists in ${shell_rc}"
        read -p "Overwrite? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled"
            return 0
        fi
        # Remove old function
        sed -i.bak '/# ACLI Docker Wrapper/,/^}/d' "${shell_rc}"
    fi

    # Add function
    cat >> "${shell_rc}" << 'EOF'

# ACLI Docker Wrapper
acli() {
    # Load config if exists
    [[ -f ~/.aclirc ]] && source ~/.aclirc

    # Configuration
    local image="${ACLI_IMAGE:-davidsmith3/acli:latest}"
    local config_dir="${ACLI_CONFIG_DIR:-${HOME}/.config/acli}"
    local workspace="${ACLI_WORKSPACE:-$(pwd)}"

    # Create config directory if needed
    [[ ! -d "${config_dir}" ]] && mkdir -p "${config_dir}"

    # Run ACLI in Docker
    docker run -it --rm \
        --user "$(id -u):$(id -g)" \
        -v "${config_dir}:/home/acli/.config/acli" \
        -v "${workspace}:/workspace" \
        -w /workspace \
        -e ACLI_CONFIG_DIR \
        "${image}" "$@"
}
EOF

    print_success "ACLI function installed successfully!"
    print_info "Run: source ${shell_rc}"
    print_info "Or restart your shell to use: acli --help"
}

# Pull Docker image
pull_image() {
    print_info "Pulling ACLI Docker image..."
    if docker pull davidsmith3/acli:latest; then
        print_success "Docker image pulled successfully"
    else
        print_error "Failed to pull Docker image"
        exit 1
    fi
}

# Main installation logic
main() {
    echo ""
    echo "ACLI Installation"
    echo "================="
    echo ""

    check_docker

    # Check if running interactively or via pipe
    local method="${1:-}"

    if [[ -z "$method" ]]; then
        if [[ -t 0 ]]; then
            # Interactive mode - stdin is a terminal
            echo ""
            echo "Choose installation method:"
            echo "  1) Install wrapper script to ${INSTALL_DIR} (recommended)"
            echo "  2) Add shell function to your shell RC file"
            echo "  3) Pull Docker image only"
            echo ""

            read -p "Enter choice [1-3]: " -n 1 -r
            echo ""
            echo ""
            method=$REPLY
        else
            # Non-interactive mode (piped) - use recommended default
            print_info "Non-interactive mode detected, using recommended method (wrapper script)"
            method=1
        fi
    fi

    echo ""

    case $method in
        1)
            install_wrapper
            ;;
        2)
            install_function
            ;;
        3)
            pull_image
            print_success "Installation complete!"
            print_info "Use: docker run --rm davidsmith3/acli --help"
            ;;
        *)
            print_error "Invalid choice: $method"
            print_info "Usage: $0 [1|2|3]"
            exit 1
            ;;
    esac

    echo ""
    print_info "Testing installation..."
    if command -v acli &> /dev/null || declare -f acli &> /dev/null; then
        print_success "Installation successful!"
        echo ""
        print_info "Get started with: acli --help"
    else
        print_warn "Please restart your shell or run: source ~/.${SHELL##*/}rc"
    fi

    echo ""
}

# Run main function
main "$@"
