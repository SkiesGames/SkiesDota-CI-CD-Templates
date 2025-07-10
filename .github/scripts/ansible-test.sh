#!/bin/bash
set -e

# Function to print section headers
print_section() {
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

# Function to test roles
test_roles() {
    print_section "TESTING ROLES"
    for role in roles/*/; do
        if [ -d "$role" ]; then
            role_name=$(basename "$role")
            echo "TESTING ROLE: $role_name"
            ansible-lint "$role" --nocolor || exit 1
        fi
    done
}

# Function to test playbooks
test_playbooks() {
    print_section "TESTING PLAYBOOKS"
    for playbook in playbooks/*.yml; do
        if [ -f "$playbook" ]; then
            playbook_name=$(basename "$playbook")
            echo "TESTING PLAYBOOK: $playbook_name"
            ansible-lint "$playbook" --nocolor || exit 1
            ansible-playbook "$playbook" --check --diff -i localhost, || exit 1
        fi
    done
}

# Install collections
ansible-galaxy collection install -r ansible/collections/requirements.yml

# Change to ansible directory to respect ansible.cfg
cd ansible

# Run testing
test_roles
test_playbooks 