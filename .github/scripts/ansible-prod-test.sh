#!/bin/bash
set -e

# Function to print section headers
print_section() {
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

# Function to test playbooks
test_playbooks() {
    print_section "TESTING PLAYBOOKS"
    
    # Test each playbook
    for playbook in playbooks/*.yml; do
        if [ -f "$playbook" ]; then
            playbook_name=$(basename "$playbook")
            echo "TESTING PLAYBOOK: $playbook_name"
            ansible-playbook "$playbook" --check --diff -i inventory.ini || exit 1
            echo "✅ $playbook_name passed"
        fi
    done
}

cd ansible

# Run testing
test_playbooks 