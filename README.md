# ACLI Docker Wrapper

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Docker](https://img.shields.io/badge/docker-enabled-brightgreen.svg)
![Security](https://img.shields.io/badge/security-non--root-success.svg)

A secure, user-friendly Docker wrapper for [Atlassian CLI (ACLI)](https://developer.atlassian.com/cloud/acli/reference/commands/).

## Contents

- [Quick Start](#quick-start)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)
- [Development](#development)
- [Contributing](#contributing)

## Quick Start

### One-Line Install

```bash
curl -sSL https://raw.githubusercontent.com/zero-to-prod/acli/main/install.sh | bash
```

### Usage After Install

```bash
# Get help
acli --help

# View Jira issue
acli jira workitem view SWE-123

# Search Jira issues
acli jira workitem search --jql "project = SWE AND status = Open"

# Get Confluence page
acli confluence page view --space DEV --title "Documentation"
```

## Installation

### Method 1: Install Wrapper Script (Recommended)

Install the wrapper script to `/usr/local/bin`:

```bash
# Download and install
sudo curl -L https://raw.githubusercontent.com/zero-to-prod/acli/main/acli.sh -o /usr/local/bin/acli
sudo chmod +x /usr/local/bin/acli

# Verify installation
acli --help
```

### Method 2: Shell Function

Add a shell function to your shell configuration:

```bash
# For Bash - add to ~/.bashrc
# For Zsh - add to ~/.zshrc

acli() {
    docker run -it --rm \
        --user "$(id -u):$(id -g)" \
        -v ~/.config/acli:/home/acli/.config/acli \
        -v "$(pwd):/workspace" \
        -w /workspace \
        davidsmith3/acli:latest "$@"
}
```

Then reload your shell:

```bash
source ~/.bashrc  # or ~/.zshrc
```

### Method 3: Direct Docker Usage

Use Docker directly without wrapper:

```bash
docker run -it --rm \
    -v ~/.config/acli:/home/acli/.config/acli \
    -v "$(pwd):/workspace" \
    davidsmith3/acli:latest --help
```

## Usage

### First Time Setup

Configure ACLI authentication on first use:

```bash
acli configure
```

Follow the prompts to add your Atlassian credentials.

### Common Commands

```bash
# Jira Operations
acli jira workitem view SWE-123
acli jira workitem view SWE-123 --fields '*all'
acli jira workitem search --jql "assignee = currentUser()"
acli jira workitem create --project SWE --type Task --summary "My Task"

# Confluence Operations
acli confluence page view --space DEV --title "Page Title"
acli confluence page list --space DEV
acli confluence space list

# Bitbucket Operations
acli bitbucket repository list
acli bitbucket pr list --repository my-repo
```

### Getting Help

```bash
# General help
acli --help

# Command-specific help
acli jira --help
acli jira workitem --help
acli confluence --help
```

## Configuration

### Environment Variables

Configure ACLI behavior using environment variables:

```bash
# Use specific image version
export ACLI_IMAGE=davidsmith3/acli:1.0.0

# Use custom config directory
export ACLI_CONFIG_DIR=~/my-custom-config

# Use custom workspace directory
export ACLI_WORKSPACE=/path/to/project
```

### Configuration File

Create `~/.aclirc` for persistent configuration:

```bash
# ~/.aclirc
ACLI_IMAGE=davidsmith3/acli:1.0.0
ACLI_CONFIG_DIR=~/.config/acli
ACLI_WORKSPACE=$(pwd)
```

The wrapper automatically loads this file if it exists.

### Config Directory Structure

ACLI stores configuration in `~/.config/acli`:

```
~/.config/acli/
├── config.json          # ACLI configuration
├── credentials.json     # Atlassian credentials
└── .cache/             # Command cache
```

## Advanced Usage

### Using with Environment Variables

```bash
# Override image version for single command
ACLI_IMAGE=davidsmith3/acli:1.0.0 acli jira workitem view SWE-123

# Use different config directory
ACLI_CONFIG_DIR=~/project-config acli jira workitem view SWE-123
```

### Batch Operations

```bash
# Process multiple issues
for issue in SWE-123 SWE-124 SWE-125; do
    acli jira workitem view "$issue" > "${issue}.json"
done

# Export all issues for a project
acli jira workitem search --jql "project = SWE" --json > all-issues.json
```

### CI/CD Integration

#### GitHub Actions

```yaml
name: Jira Sync

on: [push]

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Fetch Jira Issue
        run: |
          docker run --rm \
            -v ${{ secrets.ACLI_CONFIG }}:/home/acli/.config/acli \
            davidsmith3/acli:latest \
            jira workitem view ${{ env.ISSUE_KEY }} --json > issue.json
```

#### GitLab CI

```yaml
fetch-jira:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker run --rm davidsmith3/acli:latest jira workitem view ${ISSUE_KEY}
```

### Working with Output

```bash
# Output as JSON
acli jira workitem view SWE-123 --json

# Parse JSON with jq
acli jira workitem view SWE-123 --json | jq '.fields.summary'

# Format for readability
acli jira workitem view SWE-123 --fields summary,status,assignee
```

## Troubleshooting

### Permission Denied Errors

If you see permission errors accessing config files:

```bash
# Fix config directory permissions
chmod -R 755 ~/.config/acli

# Check ownership
ls -la ~/.config/acli
```

### Docker Not Running

Ensure Docker is running:

```bash
# Check Docker status
docker ps

# On macOS/Windows, start Docker Desktop
# On Linux, start Docker service
sudo systemctl start docker
```

### Image Pull Failures

```bash
# Pull latest image manually
docker pull davidsmith3/acli:latest

# Check Docker Hub status
curl -I https://hub.docker.com
```

### Config Not Persisting

Ensure volume mount is correct:

```bash
# Check if config directory exists
ls -la ~/.config/acli

# Create if missing
mkdir -p ~/.config/acli

# Verify volume mounting works
docker run --rm -v ~/.config/acli:/home/acli/.config/acli \
    davidsmith3/acli:latest ls -la /home/acli/.config/acli
```

### Authentication Issues

```bash
# Reconfigure authentication
acli configure

# Check credentials file
cat ~/.config/acli/credentials.json

# Test authentication
acli jira workitem search --jql "assignee = currentUser()" --maxResults 1
```

### Wrapper Script Not Found

```bash
# Check if installed
which acli

# Reinstall
curl -sSL https://raw.githubusercontent.com/zero-to-prod/acli/main/install.sh | bash

# Or install manually
sudo cp acli.sh /usr/local/bin/acli
sudo chmod +x /usr/local/bin/acli
```

### Container Exits Immediately

```bash
# Run with verbose output
docker run --rm -it davidsmith3/acli:latest --help

# Check container logs
docker logs $(docker ps -lq)

# Verify entrypoint
docker inspect davidsmith3/acli:latest | grep -A 5 Entrypoint
```

## Development

### Prerequisites

- Docker installed and running
- Make (optional, for Makefile commands)
- [Docker Buildx](https://docs.docker.com/build/buildx/install/) for multi-architecture builds

### Building Locally

```bash
# Using Make
make build

# Using Docker directly
docker build -t davidsmith3/acli:latest .

# Build with specific version
docker build --build-arg ACLI_VERSION=4.5.0 -t davidsmith3/acli:4.5.0 .
```

### Running Tests

```bash
# Using Make
make test

# Using test script directly
./test.sh davidsmith3/acli:latest
```

### Multi-Architecture Build

```bash
# Using Make
make build-multiarch

# Using Docker Buildx directly
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag davidsmith3/acli:latest \
    --load \
    .
```

### Development Commands

```bash
# Show all available commands
make help

# Build image
make build

# Run tests
make test

# Open shell in container
make shell

# Check image size
make size

# Install wrapper locally
make install

# Clean up
make clean
```

### Project Structure

```
acli/
├── Dockerfile              # Multi-stage Docker build
├── acli.sh                # Wrapper script
├── install.sh             # Installation script
├── test.sh                # Test suite
├── Makefile               # Development commands
├── docker-compose.yml     # Docker Compose config
├── README.md              # This file
├── .github/
│   └── workflows/
│       └── build.yml      # CI/CD pipeline
└── .devcontainer/
    └── devcontainer.json  # VS Code dev container
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`make test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Guidelines

- Follow shell script best practices (shellcheck)
- Add tests for new features
- Update documentation
- Keep Docker image size minimal
- Maintain backward compatibility

## License

MIT License - see [LICENSE.md](LICENSE.md) for details

## Links

- [Docker Hub](https://hub.docker.com/repository/docker/davidsmith3/acli)
- [GitHub Repository](https://github.com/zero-to-prod/acli)
- [ACLI Documentation](https://developer.atlassian.com/cloud/acli/reference/commands/)
- [Issue Tracker](https://github.com/zero-to-prod/acli/issues)

## Acknowledgments

- [Atlassian](https://www.atlassian.com/) for the ACLI tool
- [Alpine Linux](https://alpinelinux.org/) for the base image
- The open-source community

---

**Note**: This is an unofficial Docker wrapper. For official ACLI support, visit the [Atlassian Developer Portal](https://developer.atlassian.com/cloud/acli/).
