#!/usr/bin/env bash

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()   { echo -e "${YELLOW}[WARN]${NC} $*"; }

wait_for_pods() {
  local namespace="$1"
  local timeout="${2:-300}"
  local interval=5
  local elapsed=0

  elapsed=0
  log "Waiting for all pods in '$namespace' to be Ready..."
  until kubectl wait --for=condition=Ready pods --all -n "$namespace" --timeout=30s; do
    sleep $interval
    ((elapsed+=interval))
    if ((elapsed >= timeout)); then
      warn "Timeout waiting for pods in $namespace to be Ready"
      kubectl get pods -n "$namespace"
      return 1
    fi
  done
  log "All pods in '$namespace' are Ready."
}

install_manifest() {
  local url="$1"
  log "Applying manifest: $url"
  kubectl apply -f "$url"
}


if ! kubectl get namespace argocd &>/dev/null; then
  log "Creating namespace: argocd"
  kubectl create namespace argocd
else
  log "Namespace 'argocd' already exists"
fi

log "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
wait_for_pods argocd


log "Installing Istio ArgoCD Applications..."
ISTIO_APPS=(
  "https://raw.githubusercontent.com/AlexeyPetroff/argocd-gitops/main/argocd-apps/istio/istio-crd.yaml"
  "https://raw.githubusercontent.com/AlexeyPetroff/argocd-gitops/main/argocd-apps/istio/istiod.yaml"
  "https://raw.githubusercontent.com/AlexeyPetroff/argocd-gitops/refs/heads/main/argocd-apps/istio/istio-gateway.yaml"
)

for url in "${ISTIO_APPS[@]}"; do
  install_manifest "$url"
  sleep 20
done

wait_for_pods istio-system


log "Installing Flask-app ArgoCD Application..."
install_manifest "https://raw.githubusercontent.com/AlexeyPetroff/argocd-gitops/main/argocd-apps/flask-app.yaml"
wait_for_pods flask-app

log "All components installed successfully!"