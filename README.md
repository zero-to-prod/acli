# Zerotoprod\Zerotoprod\Acli

## Contents

- [Introduction](#introduction)
- [Docker Image](#docker-image)
- [Image Development](./IMAGE_DEVELOPMENT.md)
- [Contributing](#contributing)

## Introduction

A Containerized Wrapper for [Atlassian CLI](https://developer.atlassian.com/cloud/acli/reference/commands/) (ACLI).

## Docker Image

You can run the cli using the [docker image](https://hub.docker.com/repository/docker/davidsmith3/acli/general):

### Getting Help

Show available commands and options:

```shell
docker run -it --rm davidsmith3/acli --help
```

### Usage Examples

Run a specific command:

```shell
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli [COMMAND] [OPTIONS]
```

Example - Get a Jira issue:

```shell
docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli jira workitem view {workitem} --fields '*all'
```

## Contributing

Contributions, issues, and feature requests are welcome!
Feel free to check the [issues](https://github.com/zero-to-prod/acli/issues) page if you want to contribute.

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Commit changes (`git commit -m 'Add some feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Create a new Pull Request.
