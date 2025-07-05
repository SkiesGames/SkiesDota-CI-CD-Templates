#!/bin/bash

# Local linting script for Ansible code
# This script runs the same linting tools as the CI pipeline

set -e

echo "🔍 Starting local Ansible linting..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "Dockerfile.lint" ]; then
    echo "❌ Please run this script from the repository root"
    exit 1
fi

echo "📦 Building local lint image..."
docker build -f Dockerfile.lint -t local-ansible-lint .

echo "🎨 Formatting YAML files with Prettier..."
docker run --rm -v "$(pwd):/workspace" -w /workspace local-ansible-lint bash -c "
    prettier --write 'ansible/**/*.yml' 'ansible/**/*.yaml' || true
"

echo "✅ Running yamllint..."
docker run --rm -v "$(pwd):/workspace" -w /workspace local-ansible-lint bash -c "
    yamllint ansible/
"

echo "🔧 Running ansible-lint on roles..."
docker run --rm -v "$(pwd):/workspace" -w /workspace local-ansible-lint bash -c "
    for role in ansible/roles/*/; do
        echo \"CHECKING ROLE: \$role\"
        ansible-lint \"\$role\" --nocolor
    done
"

echo "📋 Running ansible-lint on playbooks..."
docker run --rm -v "$(pwd):/workspace" -w /workspace local-ansible-lint bash -c "
    for playbook in ansible/playbooks/*.yml; do
        echo \"CHECKING PLAYBOOK: \$playbook\"
        ansible-lint \"\$playbook\" --nocolor
    done
"

echo "🎉 All linting completed successfully!" 