#!/usr/bin/env bash

function setup(){
    k3d cluster create --config ../config/k3d-config.yaml

    kubectl wait --for=condition=Ready pods --all -n kube-system

    echo -e "K3D cluster was successfully initialised"
}


setup