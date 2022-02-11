# Few more steps.
## Inventory

The playbook you just downloaded contains Ansible configuration file. You have to edit this file, replacing the line

`inventory      = $HOME/Netdata/ansible/hosts`

with your actual inventory location. As an option, you can specify it in the command line:

> % ansible-playbook -i hosts demosites.yml

Of course, you might want to use your own configuration file. Ansible looks for it in the following order:

1. $ANSIBLE_CONFIG if the environment variable is set.
2. ansible.cfg if it’s in the current directory.
3. ~/.ansible.cfg if it’s in the user’s home directory.
4. /etc/ansible/ansible.cfg, the default config file.

You cannot specify multiple files as your inventories, but you may use folder. The files in such folder are always merged, allowing you just move current inventory file to this folder.

## Dry Run

You might want to perform so called dry run, when Ansible shows you all the changes without actually making them. Use the flag `--check` for this:

`% ansible-playbook demosites.yml --check`

## Setting the limits

An useful flag `--limit` allows to apply the playbook to particular host or host group. Syntax is simple:

`ansible-playbook demosites.yml --limit toronto`

allows to run the playbook against the host called 'toronto'