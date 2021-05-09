.PHONY: all clean test

.PHONY: SHELL
SHELL:=/bin/bash

#############
# VARIABLES #
#############
ANSIBLE_INVENTORY ?=

ansible_group ?= all
ansible_inventories_path ?= .inventories
ansible_output_dir ?= .output/ansible
ansible_playbook ?= ANSIBLE_CONFIG=.ansible/ansible.cfg ansible-playbook
ansible_playbooks_path ?= .ansible
ansible_requirements_path ?= .ansible/roles/requirements.yml
ansible_roles_path ?= .ansible/roles

# Dot env file only if present and ANSIBLE_INVENTORY not defined
ifeq ("$(ANSIBLE_INVENTORY)", "")
	ifneq (,$(wildcard ./.env))
		include .env
		export
	endif
endif

## —— Ⓐ  Ansible ————————————————————————————————————————————————————————————————————————————————
.PHONY: ansible-console
ansible-console: ansible-inventory-check ## Allows on-the-fly execution of Ansible modules or arbitrary commands
	ansible-console --inventory-file="$(ANSIBLE_INVENTORY)"

.PHONY: ansible-debug
ansible-debug: ansible-inventory-check ## Debug host variables # $ make ansible-debug host=hostname
	$(info Debug $(host))
	ansible --inventory=$(ANSIBLE_INVENTORY) -m setup $(host)
	ansible --inventory-file="$(ANSIBLE_INVENTORY)" --module-name="debug" --args="var=hostvars[inventory_hostname]" $(host)

.PHONY: ansible-facts
ansible-facts: ansible-inventory-check ## Allows you to collect the facts of a group # $ make ansible-facts
	ansible --module-name="setup" --inventory-file="$(ANSIBLE_INVENTORY)" --tree="$(ansible_output_dir)/facts/" $(ansible_group)
	
.PHONY: ansible-galaxy-cleanup
ansible-galaxy-cleanup: ## Empty the roles directory while preserving the requirements.yml file
	$(info Cleanup roles into ${PWD}/$(ansible_roles_path) folder, except requirements.yml file)
	rm -rf ~/.ansible_galaxy
	find $(ansible_roles_path)/* -type d -exec rm -rf {} +

.PHONY: ansible-galaxy-install
ansible-galaxy-install: ## Download all roles and their dependencies from the requirements.yml file
	$(info Install roles into ${PWD}/$(ansible_roles_path) folder)
	ansible-galaxy install --force-with-deps  --roles-path=$(ansible_roles_path) --role-file=$(ansible_requirements_path)

.PHONY: ansible-inventory-check
ansible-inventory-check: ## Checks that an inventory file is defined otherwise proposes the directories in the inventories folder. # $ ANSIBLE_INVENTORY=path/to/hosts make <target>
    ifeq ("$(ANSIBLE_INVENTORY)", "") # On propose la selection que si la variable ANSIBLE_INVENTORY est vide
		$(info Veuillez choisir le numéro d'inventaire correspondant :)
		$(eval ANSIBLE_INVENTORY = $(shell select inventory in $(ansible_inventories_path)/*; do test -n "$$inventory" && echo "$$inventory/hosts" && break;done))
		echo "L'inventaire sélectionné est : $(ANSIBLE_INVENTORY)"
    endif

.PHONY: ansible-inventory-display
ansible-inventory-display: ansible-inventory-check ## Display the inventory as seen by Ansible
	$(info Graphique de l'inventaire)
	ansible-inventory --inventory=$(ANSIBLE_INVENTORY) --graph --vars

.PHONY: ansible-inventory-grapher
ansible-inventory-grapher: ansible-inventory-check ## Creates a graph representing the tasks and roles of Ansible playbooks (Only on Debian or Ubuntu)
	$(info Graph des hotsts)
	echo -n "Cela va installer ansible-inventory-grapher, graphviz et graphicsmagick-imagemagick-compat. Êtes-vous sûr de continuer ? [y/N] " && read ans && [ $${ans:-N} = y ]
	sudo pip3 install ansible-inventory-grapher
	sudo apt install graphviz graphicsmagick-imagemagick-compat
	mkdir -p $(ansible_output_dir)
	ansible-inventory-grapher -i "$(ANSIBLE_INVENTORY)" $(ansible_group) -a "rankdir=LR; node[style=filled fillcolor=lightgrey]" | dot -T png -o $(ansible_output_dir)/inventory-grapher.png

.PHONY: ansible-inventory-list
ansible-inventory-list: ansible-inventory-check ## Displays all host information, works as an inventory script
	$(info Liste les hotst du groupe $(ansible_group))
	ansible-inventory --inventory-file="$(ANSIBLE_INVENTORY)" $(ansible_group) --list --yaml

.PHONY: ansible-playbook-lint
ansible-playbook-lint: ansible-inventory-check ## Checks the syntax of a playbook
	$(eval playbook = $(shell select file in package/*.yml; do test -n "$$file" && echo "$$file" && break;done))
	ansible-playbook --inventory-file="$(ANSIBLE_INVENTORY)" --syntax-check "$(playbook)"
