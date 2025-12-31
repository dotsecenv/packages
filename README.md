# dotsecenv Packages

The `dotsecenv` packages are hosted here for Debian/Ubuntu, Fedora/RedHat, Arch Linux/Manjaro, and macOS.

Public GPG Key: [key.asc](https://get.dotsecenv.com/key.asc)

```text
pub   rsa4096 2025-12-19 [SC] [expires: 2027-12-19]
      E60A1740BAEF49284D22EA7D3C376348F0921C59
uid           DotSecEnv Releases (Automated Release Signing Key) <release@dotsecenv.com>
sub   rsa4096 2025-12-19 [E] [expires: 2027-12-19]
```

The key can be verified using the [OpenPgp Keyserver](https://keys.openpgp.org/search?q=E60A1740BAEF49284D22EA7D3C376348F0921C59) or on [Keybase](https://keybase.io/dotsecenv).

```shell
# OpenPGP Keyserver
gpg --keyserver keys.openpgp.org --recv-keys E60A1740BAEF49284D22EA7D3C376348F0921C59

# or Keybase
curl https://keybase.io/dotsecenv/pgp_keys.asc | gpg --import
```

> [!IMPORTANT] > **For project details, documentation, and source code**
>
> **Visit the project's repository at [github.com/dotsecenv/dotsecenv](https://github.com/dotsecenv/dotsecenv).**

## Debian / Ubuntu

1. **Trust the GPG Key**:

    ```bash
    curl -fsSL https://get.dotsecenv.com/key.asc | sudo gpg --dearmor -o /etc/apt/keyrings/dotsecenv.gpg
    ```

2. **Add the Repository**:

    ```bash
    echo "deb [signed-by=/etc/apt/keyrings/dotsecenv.gpg] https://get.dotsecenv.com/apt/ ./" | sudo tee /etc/apt/sources.list.d/dotsecenv.list
    ```

3. **Install**:
    ```bash
    sudo apt-get update
    sudo apt-get install dotsecenv
    ```

## Fedora / RedHat / CentOS

1. **Add the Repository**:

    ```bash
    cat <<EOF | sudo tee /etc/yum.repos.d/dotsecenv.repo
    [dotsecenv]
    name=DotSecEnv Repository
    baseurl=https://get.dotsecenv.com/yum/
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://get.dotsecenv.com/key.asc
    EOF
    ```

2. **Install**:

    ```bash
    sudo dnf install dotsecenv
    ```

## Arch Linux / Manjaro

1. **Add to `pacman.conf`**:

    ```bash
    cat <<'EOF' | sudo tee -a /etc/pacman.conf
    [dotsecenv]
    Server = https://get.dotsecenv.com/arch/$arch
    SigLevel = Required DatabaseOptional
    EOF
    ```

2. **Trust the Key**:
    You need to locally sign the key for pacman to trust it.

    ```bash
    curl -fsSL https://get.dotsecenv.com/key.asc | sudo pacman-key --add -
    sudo pacman-key --lsign-key E60A1740BAEF49284D22EA7D3C376348F0921C59
    ```

3. **Install**:
    ```bash
    sudo pacman -Sy dotsecenv
    ```

## Linux (Direct Download)

Download the binary for your architecture:

```bash
# x86_64
curl -LO https://get.dotsecenv.com/linux/dotsecenv_0.2.1_Linux_x86_64.tar.gz

# ARM64
curl -LO https://get.dotsecenv.com/linux/dotsecenv_0.2.1_Linux_arm64.tar.gz
```

Verify and install:

```bash
# Verify checksum
curl -s https://get.dotsecenv.com/linux/checksums.txt | sha256sum -c --ignore-missing

# Extract and install
tar -xzf dotsecenv_*.tar.gz
sudo mv dotsecenv /usr/local/bin/
```

## macOS (Direct Download)

Download the binary for your architecture:

```bash
# Apple Silicon (M1/M2/M3)
curl -LO https://get.dotsecenv.com/darwin/dotsecenv_0.2.0_Darwin_arm64.tar.gz

# Intel
curl -LO https://get.dotsecenv.com/darwin/dotsecenv_0.2.0_Darwin_x86_64.tar.gz
```

Verify and install:

```bash
# Verify checksum
curl -s https://get.dotsecenv.com/darwin/checksums.txt | sha256sum -c --ignore-missing

# Extract and install
tar -xzf dotsecenv_*.tar.gz
sudo mv dotsecenv /usr/local/bin/
```

## macOS (Homebrew)

MacOS builds are also available via Homebrew. Add the tap and install:

```bash
brew tap dotsecenv/tap
brew install dotsecenv
```

## Shell Plugins

Shell plugins that automatically load `.env` and `.secenv` files when entering directories
are available for `zsh`, `bash`, and `fish`.

```bash
curl -fsSL https://raw.githubusercontent.com/dotsecenv/plugin/main/install.sh | bash
```

For plugin manager installation and additional details, see [github.com/dotsecenv/plugin#installation](https://github.com/dotsecenv/plugin#installation).
