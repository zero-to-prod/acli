#!/bin/bash
# ACLI Docker Wrapper Script
# Provides a convenient command-line interface to run ACLI in Docker

set -euo pipefail

# Configuration - can be overridden via environment variables
ACLI_IMAGE="${ACLI_IMAGE:-davidsmith3/acli:latest}"
ACLI_CONFIG_DIR="${ACLI_CONFIG_DIR:-${HOME}/.config/acli}"
ACLI_WORKSPACE="${ACLI_WORKSPACE:-$(pwd)}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again." >&2
    exit 1
fi

# Create config directory if it doesn't exist
if [[ ! -d "${ACLI_CONFIG_DIR}" ]]; then
    mkdir -p "${ACLI_CONFIG_DIR}"
fi

# Run ACLI in Docker container
exec docker run -it --rm \
    --user "$(id -u):$(id -g)" \
    -v "${ACLI_CONFIG_DIR}:/home/acli/.config/acli" \
    -v "${ACLI_WORKSPACE}:/workspace" \
    -w /workspace \
    -e ACLI_CONFIG_DIR \
    "${ACLI_IMAGE}" "$@"
