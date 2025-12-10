#!/bin/bash
set -e

# Function to print section headers
print_section() {
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

# Determine the correct path to .ansible-lint config
# If running in templates repo itself: /workspace/ansible/.ansible-lint
# If running in a project repo: /workspace/templates/ansible/.ansible-lint
if [ -f "/workspace/templates/ansible/.ansible-lint" ]; then
    LINT_CONFIG="/workspace/templates/ansible/.ansible-lint"
elif [ -f "/workspace/ansible/.ansible-lint" ]; then
    LINT_CONFIG="/workspace/ansible/.ansible-lint"
else
    echo "Warning: No .ansible-lint config found, using defaults"
    LINT_CONFIG=""
fi

if [ -n "$LINT_CONFIG" ]; then
    echo "Using ansible-lint config: $LINT_CONFIG"
    LINT_CONFIG_FLAG="--config-file=$LINT_CONFIG"
else
    LINT_CONFIG_FLAG=""
fi

# Function to lint roles
lint_roles() {
    print_section "LINTING ROLES"
    for role in collections/roles/*/; do
        if [ -d "$role" ]; then
            role_name=$(basename "$role")
            echo "LINTING ROLE: $role_name"
            # Use centralized .ansible-lint config (auto-detected)
            ansible-lint "$role" --nocolor $LINT_CONFIG_FLAG || exit 1
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
            # Use centralized .ansible-lint config (auto-detected)
            ansible-lint "$playbook" --nocolor $LINT_CONFIG_FLAG || exit 1
        fi
    done
}

# Change to ansible directory
cd ansible

# Run ansible-lint (validates both YAML syntax and Ansible best practices)
lint_roles
lint_playbooks

echo "🎉 All linting completed successfully!"
