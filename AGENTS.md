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
      linux-ci.yml          # Integration tests (Debian, openSUSE, Ubuntu containers)
      linting.yml           # Ansible Lint checks
    CODEOWNERS              # Code ownership rules
  README.md                 # User-facing documentation
  AGENTS.md                 # This file
```

## CI Workflows

Two GitHub Actions workflows run on every push and pull request:

### Integration Test (`linux-ci.yml`)

Runs `ansible-playbook tests/test.yml` inside three container environments:

| Job | Container Image |
|-----|----------------|
| `debian-test-job` | `debian:bookworm` |
| `opensuse-test-job` | `opensuse/leap:15` |
| `ubuntu-test-job` | `ubuntu:24.04` |

Each job installs Ansible inside the container, checks out the code, and runs the test playbook.

### Linting (`linting.yml`)

Runs `ansible-lint` via the `ansible/ansible-lint@main` action. The lint configuration excludes `tests/test.yml` and skips the `role-name` rule.

### Actions Pinning Convention

All GitHub Actions checkout steps use `actions/checkout@v6` (Node.js 24). Keep this version current to avoid Node.js deprecation warnings.

## Key Files

### `meta/main.yml`

Ansible Galaxy role metadata. Valid top-level keys are `galaxy_info`, `dependencies`, and `allow_duplicates` only. Do NOT add a top-level `version` key; Ansible roles derive versions from Git tags, not from role metadata.

### `defaults/main.yml`

All role variables with their defaults. See `README.md` for a complete variable reference table.

### `tasks/main.yml`

Entry point for role execution. Dispatches to platform-specific install tasks based on `ansible_facts.distribution`, then runs configuration and claiming tasks when enabled.

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
