# ACLI - Atlassian CLI Docker Wrapper

[![Docker Pulls](https://img.shields.io/docker/pulls/davidsmith3/acli?style=flat-square&logo=docker)](https://hub.docker.com/r/davidsmith3/acli)
[![Docker Image Size](https://img.shields.io/docker/image-size/davidsmith3/acli/latest?style=flat-square&logo=docker)](https://hub.docker.com/r/davidsmith3/acli)
[![GitHub License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](./LICENSE.md)
[![GitHub Release](https://img.shields.io/github/v/release/zero-to-prod/acli?style=flat-square)](https://github.com/zero-to-prod/acli/releases)

A lightweight, containerized wrapper for [Atlassian CLI](https://developer.atlassian.com/cloud/acli/reference/commands/) (ACLI) that simplifies Jira Cloud operations through Docker.

Use it to download Jira issues and interact with Jira from the command line.

Using this wrapper:
- Provides an alternative to MCP: reducing time and consuming fewer tokens
- Zero-configuration global installation
- Does not require special instructions for LLMs to use since it's just a CLI
- Use it to compose powerful scripts without the need for an MCP integration

## Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
  - [Authentication Setup](#authentication-setup-required)
  - [Environment Variables](#environment-variables)
  - [Volume Mounts](#volume-mounts)
- [Usage](#usage)
  - [Basic Commands](#basic-command-structure)
  - [Common Use Cases](#common-use-cases)
  - [Shell Aliases](#creating-shell-aliases)
- [Image Information](#image-information)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Quick Start

1. One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/zero-to-prod/acli/main/install.sh | bash
```

2. Authenticate:

Get a token from https://id.atlassian.com/manage-profile/security/api-tokens

```bash
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli:latest jira auth login
```

3. View an issue:

```bash
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli jira workitem view PROJ-123
```

4. Alias (Recommended)
Since this package is a Docker wrapper, an LLM should need no specific instructions to use the underlying CLI.

Adding an alias makes the wrapper transparent, allowing it to be used naturally.

```bash
alias acli='docker run -it --rm -v ~/.config/acli:/root/.config/acli -v $(pwd):/workspace -w /workspace davidsmith3/acli'
```

5. Run Directly (Optional)

Use this to run in non-interactive contexts such as CI/CD pipelines, scripts, or other automation.

```shell
docker run --rm -v ~/.config/acli:/root/.config/acli -v $(pwd):/workspace -w /workspace davidsmith3/acli jira workitem view [ISSUE_KEY]
```

### Manual Setup

```bash
# Pull the image
docker pull davidsmith3/acli:latest

# Authenticate (one-time setup)
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli jira auth login

# Run a command (example: view a Jira issue)
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli jira workitem view PROJ-123
```

### Creating Shell Aliases

For convenience, create an alias in your shell configuration (`.bashrc`, `.zshrc`):

```bash
alias acli='docker run -it --rm -v ~/.config/acli:/root/.config/acli -v $(pwd):/workspace -w /workspace davidsmith3/acli'
```

## Prerequisites

Before using this Docker image, ensure you have:

- **Docker**: Version 20.10+ or **Docker Desktop** (Windows/Mac)
- **Docker Compose** (optional): Version 1.29+
- **Atlassian Account**: With API token for authentication

## Installation

### Option 1: Using Docker Run (Recommended)

Pull the latest image from Docker Hub:

```bash
docker pull davidsmith3/acli:latest
```

### Option 2: Using Docker Compose

Create a `docker-compose.yml`:

```yaml
services:
  acli:
    image: davidsmith3/acli:latest
    container_name: acli
    volumes:
      - ~/.config/acli:/root/.config/acli
    environment:
      - TZ=UTC
```

Run with:
```bash
docker-compose run --rm acli --help
```

### Available Tags

- `latest` - Current stable release (recommended)
- `{X.Y.Z}` - Specific versions (e.g., `1.1.3`)
- `{X.Y}` - Major.minor versions (e.g., `1.1`)

## Configuration

### Authentication Setup (Required)

ACLI requires authentication to connect to your Atlassian instance.

#### Step 1: Create Local Configuration

Configure ACLI with your credentials:

```bash
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli jira auth login
```

Follow the interactive prompts to:
- Set your Atlassian instance URL
- Provide your email address
- Enter your API token

### Environment Variables

Optional environment variables you can set:

```bash
docker run -it --rm \
  -e ACLI_HOME=/root/.config/acli \
  -e TZ=UTC \
  -v ~/.config/acli:/root/.config/acli \
  davidsmith3/acli [COMMAND]
```

Supported variables:
- `ACLI_HOME` - Configuration directory (default: `/root/.config/acli`)
- `TZ` - Timezone setting (default: `UTC`)

### Volume Mounts

**Essential volumes:**

| Volume                              | Purpose                     | Required |
|-------------------------------------|-----------------------------|----------|
| `~/.config/acli:/root/.config/acli` | Credentials & configuration | Yes      |
| `$(pwd):/workspace`                 | Current directory access    | Optional |

**Example with workspace mount:**

```bash
docker run -it --rm \
  -v ~/.config/acli:/root/.config/acli \
  -v $(pwd):/workspace \
  -w /workspace \
  davidsmith3/acli [COMMAND]
```

### Security Considerations

- Credentials are stored in `~/.config/acli` on your host machine
- Never commit `.config/acli` to version control
- Ensure file permissions are restrictive: `chmod 700 ~/.config/acli`
- Use API tokens instead of passwords for authentication

## Usage

### Basic Command Structure

```bash
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli [COMMAND] [OPTIONS]
```

### Quick Reference

Display help:
```bash
# General help
docker run -it --rm davidsmith3/acli --help

# Command-specific help
docker run -it --rm davidsmith3/acli [COMMAND] --help
```

### Common Use Cases

#### Jira Operations

**View an issue:**
```bash
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli jira workitem view PROJ-123
```

**View with all fields:**
```bash
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli jira workitem view PROJ-123 --fields '*all'
```

**Search for issues:**
```bash
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli jira workitem search --jql "project = MY-PROJECT"
```

**Create an issue:**
```bash
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli jira workitem create \
  --project MY-PROJECT \
  --type Bug \
  --summary "Issue summary" \
  --description "Issue description"
```

**Add a comment:**
```bash
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli jira workitem comment \
  PROJ-123 \
  --add "This is a comment"
```

**Transition an issue:**
```bash
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli jira workitem transition \
  PROJ-123 \
  --name "In Progress"
```

After adding the alias, restart your shell or run `source ~/.bashrc`. Then you can use:

```bash
acli jira workitem view PROJ-123
```

### Using Docker Compose

```bash
# Run a command
docker-compose run --rm acli jira workitem search --jql "project = MY-PROJECT"

# Interactive mode
docker-compose run --rm acli
```

### Export to CSV

Export issues using JQL search with CSV format:

```bash
docker run -it --rm \
  -v ~/.config/acli:/root/.config/acli \
  -v $(pwd):/workspace \
  -w /workspace \
  davidsmith3/acli jira workitem search \
  --jql "project = MY-PROJECT" \
  --csv > export.csv
```

## Image Information

### Docker Hub

- **Repository**: [davidsmith3/acli](https://hub.docker.com/r/davidsmith3/acli)
- **Pull Command**: `docker pull davidsmith3/acli`

### Updating the Image

```bash
# Pull the latest version
docker pull davidsmith3/acli:latest

# Verify the update
docker run --rm davidsmith3/acli --version
```

## Development

For development or custom builds, see [Image Development](./IMAGE_DEVELOPMENT.md).

### Project Links

- **GitHub Repository**: [zero-to-prod/acli](https://github.com/zero-to-prod/acli)
- **Docker Hub**: [davidsmith3/acli](https://hub.docker.com/r/davidsmith3/acli)
- **ACLI Official Docs**: [Atlassian CLI Reference](https://developer.atlassian.com/cloud/acli/)

## Contributing

Contributions, issues, and feature requests are welcome!
Feel free to check the [issues](https://github.com/zero-to-prod/acli/issues) page if you want to contribute.

Please read our:
- [Contributing Guide](./CONTRIBUTING.md) - Contribution guidelines
- [Code of Conduct](./CODE_OF_CONDUCT.md) - Community standards
- [Security Policy](./SECURITY.md) - Vulnerability reporting

### How to Contribute

1. Fork the repository
2. Create a new branch (`git checkout -b feature-branch`)
3. Make your changes
4. Commit changes (`git commit -m 'Add some feature'`)
5. Push to the branch (`git push origin feature-branch`)
6. Create a Pull Request

## License

This project is licensed under the MIT License - see [LICENSE.md](./LICENSE.md) for details.

---

**Maintained by**: [ZeroToProd](https://github.com/zero-to-prod)
**Last Updated**: 2025-11-16