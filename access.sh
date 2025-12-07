#!/bin/bash
# This script fetches URLs and credentials for ArgoCD, Prometheus & Grafana

aws configure
aws eks update-kubeconfig --region "us-east-1" --name "amazon-prime-cluster"

# ArgoCD Access
argo_url=$(kubectl get svc -n argocd | grep argocd-server | awk '{print $4}' | head -n 1)
argo_user="admin"
argo_initial_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

# Prometheus Access
prometheus_url=$(kubectl get svc -n prometheus | grep kube-prometheus-stack-prometheus | awk '{print $4}')
prometheus_port="9090"

# Grafana Access
grafana_url=$(kubectl get svc -n prometheus | grep kube-prometheus-stack-grafana | awk '{print $4}')
grafana_user="admin"
grafana_password=$(kubectl get secret -n prometheus kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)

# Print URLs and Credentials
echo "------------------------------"
echo "ArgoCD URL: $argo_url"
echo "ArgoCD User: $argo_user"
echo "ArgoCD Initial Password: $argo_initial_password"
echo
echo "Prometheus URL: http://$prometheus_url:$prometheus_port"
echo
echo "Grafana URL: http://$grafana_url"
echo "Grafana User: $grafana_user"
echo "Grafana Password: $grafana_password"
echo "------------------------------"
