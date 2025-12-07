#!/bin/bash
# access.sh - Complete EKS Cluster Access (amazon-prime-cluster)
# Usage: chmod +x access.sh && ./access.sh

set -e

CLUSTER_NAME="amazon-prime-cluster"
REGION="us-east-1"
NAMESPACE="kube-system"

echo "🔐 Checking AWS credentials..."
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "❌ Set AWS credentials first:"
    echo "export AWS_ACCESS_KEY_ID=xxx AWS_SECRET_ACCESS_KEY=yyy AWS_DEFAULT_REGION=us-east-1"
    exit 1
fi

echo "✅ AWS OK | 🔄 Updating kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

echo "⏳ Waiting for services (30s)..."
sleep 30

echo "═══════════════════════════════════════════════════════════════"
echo "🚀 EKS CLUSTER ACCESS - $CLUSTER_NAME"
echo "═══════════════════════════════════════════════════════════════"

# 1. EKS Cluster Info
echo "📋 CLUSTER INFO:"
kubectl cluster-info | head -3
echo

# 2. ArgoCD
echo "🐙 ARGOCD:"
if kubectl get namespace argocd >/dev/null 2>&1; then
    ARGOCD_SVC=$(kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{.status.loadBalancer.ingress[0].ip}{"PENDING"}' 2>/dev/null || echo "PENDING")
    ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "NOT FOUND")
    echo "  URL:        http://$ARGOCD_SVC:443"
    echo "  User:       admin"
    echo "  Password:   $ARGOCD_PASS"
    echo "  Port-forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
else
    echo "  ❌ ArgoCD not deployed"
fi
echo

# 3. Prometheus & Grafana (kube-prometheus-stack)
echo "📊 MONITORING:"
if kubectl get namespace prometheus >/dev/null 2>&1; then
    PROM_SVC=$(kubectl get svc -n prometheus -l app.kubernetes.io/name=prometheus -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    GRAF_SVC=$(kubectl get svc -n prometheus -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    
    if [ -n "$PROM_SVC" ]; then
        PROM_URL=$(kubectl get svc $PROM_SVC -n prometheus -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{.status.loadBalancer.ingress[0].ip}{"PENDING"}' 2>/dev/null || echo "PENDING")
        echo "  Prometheus: http://$PROM_URL:9090"
        echo "  Port-forward: kubectl port-forward svc/$PROM_SVC -n prometheus 9090:9090"
    fi
    
    if [ -n "$GRAF_SVC" ]; then
        GRAF_URL=$(kubectl get svc $GRAF_SVC -n prometheus -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{.status.loadBalancer.ingress[0].ip}{"PENDING"}' 2>/dev/null || echo "PENDING")
        GRAF_PASS=$(kubectl get secret -n prometheus kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d 2>/dev/null || echo "NOT FOUND")
        echo "  Grafana:    http://$GRAF_URL:3000"
        echo "  User:       admin"
        echo "  Password:   $GRAF_PASS"
        echo "  Port-forward: kubectl port-forward svc/$GRAF_SVC -n prometheus 3000:80"
    fi
else
    echo "  ❌ Monitoring not deployed"
fi
echo

# 4. Node Groups & Nodes
echo "🏗️  NODES:"
kubectl get nodes -o wide | head -5
echo

# 5. Quick Commands
echo "⚡ QUICK ACCESS:"
echo "  ArgoCD:      kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  Grafana:     kubectl port-forward svc/$(kubectl get svc -n prometheus -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].metadata.name}' 2>/dev/null) -n prometheus 3000:80"
echo "  Prometheus:  kubectl port-forward svc/$(kubectl get svc -n prometheus -l app.kubernetes.io/name=prometheus -o jsonpath='{.items[0].metadata.name}' 2>/dev/null) -n prometheus 9090:9090"
echo "  Logs:        kubectl logs -n kube-system -l k8s-app=kube-proxy"
echo

# 6. Validation
echo "✅ STATUS CHECK:"
kubectl get ns | grep -E "(argocd|prometheus)" || echo "  Namespaces OK"
kubectl get pods -A | grep -E "(Running|Completed)" | wc -l | xargs echo "  Healthy pods:"

echo "═══════════════════════════════════════════════════════════════"
echo "🎉 READY! Open browser tabs above or use port-forward commands"
echo "💾 Save this output: ./access.sh > cluster-access.txt"
