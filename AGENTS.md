# AGENTS.md

Guidelines for AI agents working on this repository.

## Project Overview

This is an Ansible role (`netdata`) that deploys and configures the [Netdata](https://www.netdata.cloud/) monitoring agent on Linux systems. It supports Debian, Ubuntu, and openSUSE platforms.

## Repository Structure

This repository follows the standard Ansible role directory layout:

```
netdata-ansible/
  defaults/main.yml        # Default variable values for the role
  handlers/main.yml        # Handlers (restart Netdata, reload claiming state)
  meta/main.yml            # Role metadata for Ansible Galaxy
  tasks/
    main.yml               # Top-level task dispatcher
    install-debian.yml      # Debian/Ubuntu package installation
    install-opensuse.yml    # openSUSE package installation
    configure-linux.yml     # Configuration file management
    node_claim.yml          # Netdata Cloud node claiming
  templates/
    claim.conf.j2           # Claiming configuration template
    go.d/plugin.conf.j2     # Go collector plugin configuration template
  tests/
    test.yml                # CI integration test playbook
    netdata.conf.j2         # Test configuration template
    example.chart.j2        # Test chart template
  .github/
    workflows/
      linux-ci.yml          # Integration tests (matrix strategy, 6 OS versions)
      linting.yml           # Ansible Lint checks
    CODEOWNERS              # Code ownership rules
  README.md                 # User-facing documentation
  AGENTS.md                 # This file
```

## CI Workflows

Two GitHub Actions workflows run on every push and pull request:

### Integration Test (`linux-ci.yml`)

Uses GitHub Actions matrix strategy to run `ansible-playbook tests/test.yml` across six container environments, organized into two jobs by package manager:

**`apt-test`** (Debian and Ubuntu, uses `apt-get`):

| Container Image |
|----------------|
| `debian:bullseye` |
| `debian:bookworm` |
| `ubuntu:22.04` |
| `ubuntu:24.04` |

**`opensuse-test`** (openSUSE Leap, uses `zypper`):

| Container Image | `community.general` Version |
|----------------|----------------------------|
| `opensuse/leap:15.5` | 3.8.8 (pinned) |
| `opensuse/leap:15.6` | latest |

Both jobs set `fail-fast: false` so all matrix entries run even if one fails. Each job installs Ansible inside the container, checks out the code, and runs the test playbook. The `opensuse-test` job additionally installs the `community.general` Ansible collection via `ansible-galaxy`, because the openSUSE Leap `ansible` package does not bundle it. This collection provides the `community.general.zypper` and `community.general.zypper_repository` modules that the role requires.

The `opensuse-test` matrix uses `include` entries with a `community_general_version` variable to control the installed collection version per image. openSUSE Leap 15.5 ships Python 3.6, which is incompatible with `community.general` 4.0+ (those releases use `from __future__ import annotations`, a Python 3.7+ feature). The 15.5 entry pins `community.general` to 3.8.8, the last release supporting Python 3.6 and Ansible 2.9. The 15.6 entry installs the latest version. When adding new openSUSE matrix entries, check the Python version in the container and set `community_general_version` accordingly.

### Linting (`linting.yml`)

Runs `ansible-lint` via the `ansible/ansible-lint@main` action. The lint configuration excludes `tests/test.yml` and skips the `role-name` rule.

### Actions Pinning Convention

All GitHub Actions checkout steps use `actions/checkout@v6` (Node.js 24). Keep this version current to avoid Node.js deprecation warnings.

## Key Files

### `meta/main.yml`

Ansible Galaxy role metadata. Valid top-level keys are `galaxy_info`, `dependencies`, and `allow_duplicates` only. Do NOT add a top-level `version` key; Ansible roles derive versions from Git tags, not from role metadata.

The `galaxy_info.platforms` list declares supported platforms for Ansible Galaxy. Platform names and version strings must match the ansible-lint `schema[meta]` rule. When a specific OS minor version is not in the Galaxy schema's allowed enum, use `versions: [all]` instead of explicit version numbers.

### `defaults/main.yml`

All role variables with their defaults. See `README.md` for a complete variable reference table.

### `tasks/main.yml`

Entry point for role execution. Dispatches to platform-specific install tasks based on `ansible_facts.distribution`, then runs configuration and claiming tasks when enabled.

### `tasks/install-debian.yml`

Handles Debian and Ubuntu package installation. Uses the modern `signed-by` keyring approach for GPG key management:

1. Installs `gnupg` (required for key dearmoring).
2. Creates `/etc/apt/keyrings/` directory.
3. Downloads the ASCII-armored GPG key to `/etc/apt/keyrings/netdata.asc`.
4. Dearmors the key to binary format at `/etc/apt/keyrings/netdata.gpg`.
5. References the binary keyring via `[signed-by=...]` in the apt source line.

Do NOT use `ansible.builtin.apt_key` in this file. It wraps the deprecated `apt-key` utility, which fails on Debian 12+ and Ubuntu 22.04+ with subkey validation errors.

### `tasks/install-opensuse.yml`

Handles openSUSE Leap package installation. Installs `libnetfilter_acct1` from the standard Leap repositories, imports the Netdata GPG key, adds the Netdata package repository, and installs the `netdata` package (plus optional chart support).

All zypper-related tasks use the `community.general` collection (`community.general.zypper` and `community.general.zypper_repository`). This collection must be available on the control node.

Do NOT add Tumbleweed repository URLs in this file. Tumbleweed is a separate rolling-release distribution; its repository URLs are invalid on Leap systems and cause connection failures. The `libnetfilter_acct1` package is available from the standard Leap Main Repository and does not require an external repository.

## Conventions

### YAML Style

- Use `---` document start markers in Ansible YAML files.
- Use fully qualified collection names for modules (e.g., `ansible.builtin.setup`, not `setup`).
- Quote string values in variable definitions.

### Task Naming

- Every task must have a `name` field with a descriptive label.
- Use the pattern: verb + object (e.g., "Install dependencies", "Configure Netdata").

### Testing

- The integration test playbook is `tests/test.yml`. It runs the role against `localhost` with `netdata_manage_config: true` and `netdata_manage_charts: true`.
- CI tests validate that the role installs successfully. They do not validate Netdata runtime behavior (the containers do not run systemd).

### Variable Naming

- All role variables are prefixed with `netdata_`.
- Boolean variables use `true`/`false`, not `yes`/`no`.

### Commit Messages

- Follow conventional commit format: `type: description`.
- Common types: `fix`, `feat`, `docs`, `ci`, `refactor`.
- Keep the subject line concise (under 72 characters).
