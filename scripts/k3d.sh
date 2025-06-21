#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/.."

function setup(){
    k3d cluster create --config "$REPO_ROOT/config/k3d-config.yaml"

    kubectl wait --for=condition=Ready pods --all -n kube-system

    echo -e "K3D cluster was successfully initialised"
}


setup