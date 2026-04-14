#!/bin/bash

set -e

CLUSTER_NAME="redis-cluster"
EXPECTED_CONTEXT="kind-redis-cluster"
IMAGE_NAME="python-api:latest"

echo "Checking Docker..."
docker info > /dev/null 2>&1 || {
  echo "Docker is not running or not reachable."
  exit 1
}

echo "Checking kubectl..."
command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl is not installed."
  exit 1
}

echo "Checking kind..."
command -v kind >/dev/null 2>&1 || {
  echo "kind is not installed."
  exit 1
}

echo "Checking current kubectl context..."
CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || true)

if [ "$CURRENT_CONTEXT" != "$EXPECTED_CONTEXT" ]; then
  echo "Current context is '$CURRENT_CONTEXT'"
  echo "Switching to '$EXPECTED_CONTEXT'..."
  kubectl config use-context "$EXPECTED_CONTEXT"
fi

echo "Loading Docker image into kind cluster..."
kind load docker-image "$IMAGE_NAME" --name "$CLUSTER_NAME"

echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/redis-configmap.yaml
kubectl apply -f k8s/redis-secret.yaml
kubectl apply -f k8s/redis-pvc.yaml
kubectl apply -f k8s/redis-deployment.yaml
kubectl apply -f k8s/redis-service.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/debug-pod.yaml

echo "Installing ingress-nginx (official kind provider manifest)..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Applying app ingress..."
kubectl apply -f k8s/ingress.yaml

echo "Waiting for Redis deployment to be ready..."
kubectl rollout status deployment/redis --timeout=120s

echo "Waiting for FastAPI deployment to be ready..."
kubectl rollout status deployment/python-api --timeout=120s

echo "Waiting for debug pod to be ready..."
kubectl wait --for=condition=Ready pod/debug-client --timeout=120s

echo "Waiting for ingress-nginx controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "Current pods:"
kubectl get pods

echo "Current services:"
kubectl get svc

echo "Ingress resources:"
kubectl get ingress

echo "Startup complete."