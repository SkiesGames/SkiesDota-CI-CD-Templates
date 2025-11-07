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
    
    # Test each playbook with syntax check only (no SSH connection required)
    for playbook in playbooks/*.yml; do
        if [ -f "$playbook" ]; then
            playbook_name=$(basename "$playbook")
            echo "TESTING PLAYBOOK: $playbook_name"
            ansible-playbook "$playbook" --syntax-check || exit 1
            echo "✅ $playbook_name passed syntax check"
        fi
    done
}

cd ansible

# Run testing
test_playbooks 