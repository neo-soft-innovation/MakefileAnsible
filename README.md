# Makefile for Ansible

This repository provides a Makefile to give you a simple interface for Ansible.

## Why?

- Simplify your CLI ansible runs
- Don't Repeat Yourself while typing ansible commands
- Easier adoption for people that are not used to Ansible
- Document common usage

## Installation

Simply download the `Makefile` in your project directory.

```bash
mkdir -p .vendor/make/ansible
wget -qO- "https://github.com/neo-soft-innovation/makefile-ansible.git" | tar xvz --strip-components 1 -C .vendor/make/ansible
```

## Commands

This is the list of commands made available

```bash
> make
ansible-console                make ansible-console # Allows on-the-fly execution of Ansible modules or arbitrary commands
ansible-debug                  make ansible-debug [host=hostname] # Debug host variables
ansible-facts                  make ansible-facts # Allows you to collect the facts of a group
ansible-galaxy-cleanup         make ansible-galaxy-cleanup # Empty the roles directory while preserving the requirements.yml file
ansible-galaxy-install         make ansible-galaxy-install # Download all roles and their dependencies from the requirements.yml file
ansible-inventory-check        make ansible-inventory-check # Checks that an inventory file is defined otherwise proposes the directories in the inventories folder
ansible-inventory-display      make ansible-inventory-display # Display the inventory as seen by Ansible
ansible-inventory-grapher      make ansible-inventory-grapher # Creates a graph representing the tasks and roles of Ansible playbooks (Only on Debian or Ubuntu)
ansible-inventory-list         make ansible-inventory-list # Displays all host information, works as an inventory script
ansible-playbook-lint          make ansible-playbook-lint # Checks the syntax of a playbook
```

## Variables

This is the explanation of variables that can be passed to commands:

| Name                        | Default                                                | Description                  | Example                                                                   |
| --------------------------- | ------------------------------------------------------ | ---------------------------- | ------------------------------------------------------------------------- |
| `ANSIBLE_INVENTORY`         | -                                                      | Path to inventory hosts file | `ANSIBLE_INVENTORY=~/workspace/inventories/myrpoject/hosts make <target>` |
| `ansible_group`             | `all`                                                  | -                            | -                                                                         |
| `ansible_output_dir`        | `.output/ansible`                                      | -                            | -                                                                         |
| `ansible_playbook`          | `ANSIBLE_CONFIG=.ansible/ansible.cfg ansible-playbook` | -                            | -                                                                         |
| `ansible_playbooks_path`    | `.ansible`                                             | -                            | -                                                                         |
| `ansible_requirements_path` | `.ansible/roles/requirements.yml`                      | -                            | -                                                                         |
| `ansible_roles_path`        | `.ansible/roles`                                       | -                            | -                                                                         |

## License

**[MIT License](LICENSE)**

Copyright(c) 2021 [neo-soft](https://github.com/neo-soft-innovation)
