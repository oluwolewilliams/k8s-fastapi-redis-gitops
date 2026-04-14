#!/bin/bash

set -e

EXPECTED_CONTEXT="kind-redis-cluster"
CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || true)

if [ "$CURRENT_CONTEXT" != "$EXPECTED_CONTEXT" ]; then
  echo "Current context is '$CURRENT_CONTEXT'"
  echo "Switching to '$EXPECTED_CONTEXT'..."
  kubectl config use-context "$EXPECTED_CONTEXT"
fi

echo "Forwarding local port 8000 to service/python-api port 80..."
echo "Open another terminal to test the API."
kubectl port-forward svc/python-api 8000:80