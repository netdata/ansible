# Netdata Ansible

An Ansible role for deploying and configuring the [Netdata](https://www.netdata.cloud/) monitoring agent on Linux systems.

## Supported Platforms

- Debian 11 (Bullseye)
- Debian 12 (Bookworm)
- Ubuntu 22.04 (Jammy)
- Ubuntu 24.04 (Noble)
- openSUSE Leap 15.6
- openSUSE Leap 16.0

## Requirements

- Ansible 2.1 or later
- Target hosts must use `systemd` as their service manager

## Installation

Include the role in your playbook or install it via Ansible Galaxy:

```bash
ansible-galaxy install netdata.netdata
```

## Usage

### Basic Installation

Install Netdata with default settings (stable release channel):

```yaml
- hosts: all
  roles:
    - role: netdata
```

### Claim Node to Netdata Cloud

Install Netdata and register the node with your Netdata Cloud account:

```yaml
- hosts: all
  roles:
    - role: netdata
      vars:
        netdata_claim: true
        netdata_claim_token: "YOUR_NETDATA_CLAIM_TOKEN"
        netdata_claim_rooms: "YOUR_ROOM_ID"
```

### Use the Nightly (Edge) Release Channel

Set `netdata_release_channel` to `nightly` or `edge` to install the latest development builds:

```yaml
- hosts: all
  roles:
    - role: netdata
      vars:
        netdata_release_channel: "nightly"
```

### Custom Configuration and Charts

Manage Netdata configuration files and custom chart templates:

```yaml
- hosts: all
  roles:
    - role: netdata
      vars:
        netdata_claim: true
        netdata_claim_token: "YOUR_NETDATA_CLAIM_TOKEN"
        netdata_manage_config: true
        netdata_manage_charts: true
        netdata_custom_config_path: "/path/to/custom/netdata.conf.j2"
        netdata_custom_charts_path: "/path/to/custom/charts/"
```

### Go Collector Plugins

Configure Go-based collector plugins (for example, Prometheus scraping):

```yaml
- hosts: all
  roles:
    - role: netdata
      vars:
        netdata_manage_config: true
        netdata_go_collector_plugins:
          - name: prometheus
            config:
              job:
                - name: local
                  url: http://127.0.0.1:9090/metrics
```

## Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `netdata_release_channel` | Release channel: `stable`, `nightly`, or `edge`. `nightly` is an alias for `edge`. | `"stable"` |
| `netdata_manage_config` | Enable management of Netdata configuration files. | `false` |
| `netdata_manage_charts` | Enable installation of chart support and custom chart templates. | `false` |
| `netdata_config_dir` | Path to the Netdata configuration directory. | `"/etc/netdata"` |
| `netdata_custom_config_path` | Path to a custom `netdata.conf.j2` Jinja2 template. Leave empty to skip. | `""` |
| `netdata_chart_dir` | Path to the Netdata charts.d plugin directory. | `"/usr/libexec/netdata/charts.d"` |
| `netdata_custom_charts_path` | Path to a directory of custom `.j2` chart templates. Leave empty to skip. | `""` |
| `netdata_claim` | Enable Netdata Cloud node claiming. | `false` |
| `netdata_claim_token` | Claim token from Netdata Cloud. | `""` |
| `netdata_claim_url` | Netdata Cloud claim URL. | `"https://app.netdata.cloud"` |
| `netdata_claim_rooms` | Comma-separated list of Netdata Cloud room IDs. | `""` |
| `netdata_proxy` | Proxy URL for Netdata Cloud connections. Leave empty to disable. | `""` |
| `netdata_go_collector_plugins` | List of Go collector plugin configurations. See usage example above. | `[]` |

## License

Apache-2.0
