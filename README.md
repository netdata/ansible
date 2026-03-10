# Netdata Ansible

## Tested on

- Debian 12
- SUSE Linux Enterprise Server 15

## Utilization

To install Netdata on a host, you can use the following playbook:

```yaml
- hosts: all
  roles:
    - role: netdata
```

To install Netdata on a host and configure it to send metrics to a Netdata Cloud account, you can use the following playbook:

```yaml
- hosts: all
  roles:
    - role: netdata
      vars:
        netdata_claim: true
        netdata_claim_token: "YOUR_NETDATA_CLAIM_TOKEN"
```

To install Netdata on a host and enable custom configuration or charts, you can use the following playbook:

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
