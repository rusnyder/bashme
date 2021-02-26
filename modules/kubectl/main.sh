#! /usr/bin/env bash

export KUBECONFIG="$HOME/.kube/config:$HOME/.kube/mk/minikube:$HOME/.kube/eks/blue:$HOME/.kube/eks/preprod:$HOME/.kube/eks/demo:$HOME/.kube/eks/prod:$HOME/.kube/dev-data-pipeline.kubeconfig"

# Add bash completion
# shellcheck disable=SC1090
source <(kubectl completion bash)
