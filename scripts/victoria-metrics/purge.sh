#!/bin/bash
# Proper Victoria Metrics Cleanup Script
# Run this when you need to cleanup Victoria Metrics

set -e

echo "🔄 Starting Victoria Metrics cleanup..."

# 1. Delete custom resources first (let operator clean them up)
echo "🗑️  Deleting Victoria Metrics custom resources..."
kubectl delete vmcluster --all --all-namespaces --wait=true --timeout=30s
kubectl delete vmalertmanager --all --all-namespaces --wait=true --timeout=30s
kubectl delete vmsingle --all --all-namespaces --wait=true --timeout=30s

# 2. Wait a bit for cleanup
echo "⏳ Waiting for operator cleanup..."
sleep 30

# 3. Force delete namespace if it exists (as last resort)
if kubectl get ns victoria-metrics &>/dev/null; then
    echo "🗑️  Force deleting namespace..."
    kubectl delete ns victoria-metrics --timeout=60s || {
        echo "⚠️  Namespace stuck, removing finalizers..."
        # Remove finalizers from remaining resources
        kubectl get all,secrets,sa,roles,rolebindings,pvc -n victoria-metrics -o name | while read resource; do
            kubectl patch "$resource" -n victoria-metrics --type json --patch='[{"op": "remove", "path": "/metadata/finalizers"}]' 2>/dev/null || true
        done
        kubectl delete ns victoria-metrics --timeout=30s
    }
fi

# 4. Clean up any orphaned PVs
echo "🧹 Cleaning up orphaned PVs..."
kubectl get pv | grep victoria-metrics | awk '{print $1}' | xargs -r kubectl delete pv --timeout=30s || true

echo "✅ Cleanup complete. Ready for fresh installation."
