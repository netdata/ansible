# Example of basic Netdata agent management using Ansible
## Prerequisites
Tested with Ansible v. 2.12.1; should work with any Ansible version since 2.9

You have to edit the inventory file `hosts` and, perhaps, `ansible.cfg`.

Requires jmespath installed on the host system
## Tested on
`Centos 7, Rocky 8`

`Debian 10, Debian 11`,`Ubuntu 20`

## Playbook components, a short description
> netdata-agent.yml:

Installs Netdata Packagecloud repository whenever possible.
Installs Netdata agent latest available version, trying to avoid installation from other repositories.

> purge.yml:

Removes both installed repository and the package, making efforts to remove all possible remains like the log or configuration files.

> claim.yml:

Claims the agent against Netdata Cloud

## Parameters

Playbooks behavior is parameterized to some extent. You may add or change the global settings in `group_vars/all` file or on per host basis in corresponding files in `host_vars/`
You might also want to set some parameters in inventory file, of course. Or directly in the command line. Examples:

`ansible-playbook --limit=debian10,ubuntu20 netdata-agent.yml`

`ansible-playbook -u toor --limit=rocky8 -e "distro=edge" purge.yml`

*Warning.*

You cannot just switch from stable to edge repos (nor visa versa). You have to purge existing installation first.

## To do

- The only agent configuration file used for the time being is `netdata.conf`. Perhaps, other configuration files handling should be added.