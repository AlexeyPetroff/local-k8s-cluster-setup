# Local GitOps Environment: k3d + ArgoCD + Istio + Flask App

This repository contains scripts and manifests to quickly spin up a local [k3d](https://k3d.io/) Kubernetes cluster, install [Argo CD](https://argo-cd.readthedocs.io/), and deploy a sample Flask application and Istio resources using GitOps principles.

- **ArgoCD GitOps repo:** [AlexeyPetroff/argocd-gitops](https://github.com/AlexeyPetroff/argocd-gitops)
- **Flask app source:** [AlexeyPetroff/flask-app](https://github.com/AlexeyPetroff/flask-app) The image is built and pushed to GitHub Container Registry (ghcr) via GitHub Actions

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [Accessing Your Apps](#accessing-your-apps)
- [Cleaning Up](#cleaning-up)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Overview

**What’s automated:**

- Local Kubernetes cluster creation (k3d)
- Installation of ArgoCD and Istio via scripts
- Declarative deployment of a Flask app and Istio resources using ArgoCD Applications from a Git repo

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (for Mac, Linux, or Windows)
- [k3d](https://k3d.io/) (for running Kubernetes in Docker)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (Kubernetes CLI)

> **Tip:**  
> Make sure Docker is running and you have sufficient resources (at least 4GB RAM recommended).

---

## Quick Start

1. **Clone this repository:**
    ```
    git clone https://github.com/AlexeyPetroff/local-k8s-cluster-setup.git
    cd local-k8s-cluster-setup
    ```

2. **Create the k3d cluster:**
    ```
    ./scripts/k3d.sh
    ```
    This script will create a k3d cluster with ports mapped for Istio ingress.

3. **Install ArgoCD and deploy applications:**
    ```
    ./install_argocd.sh
    ```
    This script installs ArgoCD, waits for it to be ready, then applies ArgoCD Applications for Istio and the Flask app.

4. **(Optional) Access ArgoCD UI:**
    ```
    kubectl port-forward svc/argocd-server -n argocd 9090:443
    ```
    Visit [https://localhost:9090](https://localhost:9090)  
    Get the admin password:
    ```
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
    ```

---

## How It Works

- **k3d** spins up a multi-node local Kubernetes cluster inside Docker, with ports mapped for ingress.
- **ArgoCD** is installed and configured to watch the [argocd-gitops](https://github.com/AlexeyPetroff/argocd-gitops) repository.
- **Istio** is deployed as an ArgoCD Application, providing service mesh and ingress.
- **Flask app** is deployed as an ArgoCD Application, using a container image built and pushed via GitHub Actions.

All cluster state is managed declaratively via GitOps.  
Any change to the `argocd-gitops` repo is automatically picked up by ArgoCD and applied to the cluster.

---

## Accessing the Apps

- **Flask app:**  
  By default, exposed via Istio ingress at `http://flask-app.local:8080/`
  - Port forward istio ingress:
    ```
    kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
    ```
  - Then access the app:
    ```
    curl -H "Host: flask-app.local" http://localhost:8080/
    ```

---

## Cleaning Up

To delete your k3d cluster and all resources:
```
k3d cluster delete local-istio-cluster
```
