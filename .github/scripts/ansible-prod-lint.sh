#!/bin/bash
set -e

# Function to print section headers
print_section() {
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

# Function to lint roles
lint_roles() {
    print_section "LINTING ROLES"
    for role in collections/roles/*/; do
        if [ -d "$role" ]; then
            role_name=$(basename "$role")
            echo "LINTING ROLE: $role_name"
            ansible-lint "$role" --nocolor || exit 1
        fi
    done
}

# Function to lint playbooks
lint_playbooks() {
    print_section "LINTING PLAYBOOKS"
    for playbook in playbooks/*.yml; do
        if [ -f "$playbook" ]; then
            playbook_name=$(basename "$playbook")
            echo "LINTING PLAYBOOK: $playbook_name"
            ansible-lint "$playbook" --nocolor || exit 1
        fi
    done
}

# Change to ansible directory
cd ansible

# Run ansible-lint (validates both YAML syntax and Ansible best practices)
lint_roles
lint_playbooks

echo "🎉 All linting completed successfully!"
