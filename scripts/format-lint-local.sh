#!/bin/bash
set -e

echo "🎨 Formatting YAML files with Prettier..."
prettier --write 'ansible/**/*.yml'

echo "✅ YAML files formatted successfully"

echo "🔍 Validating with ansible-lint..."
cd ansible
ansible-lint collections/roles/ playbooks/

echo "🎉 All formatting and validation completed successfully!" 