# Documentation Summary: Fix openSUSE CI Failures

## Changes Made

### `AGENTS.md`

Two updates to reflect the openSUSE CI fixes:

1. **CI Workflows section (Integration Test)**: Added a sentence documenting that the `opensuse-test` job installs the `community.general` Ansible collection via `ansible-galaxy`. This clarifies why the collection install step exists and what modules it provides (`community.general.zypper` and `community.general.zypper_repository`).

2. **Key Files section (new entry: `tasks/install-opensuse.yml`)**: Added a documentation block for the openSUSE install task file, parallel to the existing `tasks/install-debian.yml` entry. Documents three key points:
   - The file handles openSUSE Leap package installation (dependencies, GPG key, repo, package).
   - All zypper tasks require the `community.general` collection on the control node.
   - A "Do NOT" warning against adding Tumbleweed repository URLs, explaining that Tumbleweed is a separate distribution with incompatible URLs.

### `README.md`

No changes. The fixes are internal (CI workflow configuration and role task internals). They do not affect user-facing behavior, role variables, supported platforms, or usage patterns.

## Verification

- Confirmed `AGENTS.md` edits are accurate against the actual file states of `tasks/install-opensuse.yml` (44 lines, no Tumbleweed references) and `.github/workflows/linux-ci.yml` (line 49: `ansible-galaxy collection install community.general`).
- Confirmed the new Key Files entry describes the current task structure: `libnetfilter_acct1` install, GPG key import, Netdata repo addition, package install, and optional chart support.
- Confirmed no user-facing changes require README.md updates.
