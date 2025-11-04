---
url: https://developer.atlassian.com/cloud/acli/guides/install-linux/
---

# Install on Linux

## Install using package management

Use package management to install, update, and remove software packages by using either of the following methods:

### Debian-based distributions

Open a terminal window and enter the command below to install:

1. Download required dependencies:

```sh
sudo apt-get install -y wget gnupg2
```

2. Setup APT Repository:

```sh
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -nv -O- https://acli.atlassian.com/gpg/public-key.asc | sudo gpg --dearmor -o /etc/apt/keyrings/acli-archive-keyring.gpg
sudo chmod go+r /etc/apt/keyrings/acli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/acli-archive-keyring.gpg] https://acli.atlassian.com/linux/deb stable main" | sudo tee /etc/apt/sources.list.d/acli.list > /dev/null
```

3. Install ACLI:

```shell
sudo apt update sudo apt install -y acli
```

### Red Hat-based distributions

Open a terminal window and enter the command below to install:

1. Download required dependencies:

```shell
sudo yum install -y yum-utils
```

2. Setup YUM repository:

```shell
sudo yum-config-manager --add-repo https://acli.atlassian.com/linux/rpm/acli.repo
```

3. Install ACLI:

```shell
sudo yum install -y acli
```

## Install binary with curl on Linux

Open a terminal window and enter the command below to install:

1. Download the latest release:

_ARM64_

```shell
curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_arm64/acli"
```

_x86-64_

```shell
curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli"
```

2. Make the `acli` binary executable:

```shell
chmod +x ./acli
```

You can now use `acli` from this directory:

```shell
./acli --help
```

3. Install `acli` binary (requires root access):

```shell
sudo install -o root -g root -m 0755 acli /usr/local/bin/acli
```

If you do not have root access on the target system, you can still install acli to the `~/.local/bin` directory:

```shell
mkdir -p ~/.local/bin mv ./acli ~/.local/bin/acli # and then append (or prepend) ~/.local/bin to $PATH
```

You can now use `acli` globally:

```shell
acli --help
```
