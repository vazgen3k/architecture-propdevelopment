#!/usr/bin/env bash
set -euo pipefail

USERNAME="$1"
GROUPNAME="$2"
CLUSTER_NAME="minikube"
BASE_DIR="$(pwd)/k8s-users/${USERNAME}"

mkdir -p "${BASE_DIR}"

echo "Generate private key..."
openssl genrsa -out "${BASE_DIR}/${USERNAME}.key" 2048

openssl req -new \
  -key "${BASE_DIR}/${USERNAME}.key" \
  -out "${BASE_DIR}/${USERNAME}.csr" \
  -subj "/CN=${USERNAME}/O=${GROUPNAME}"

echo "Sign certificate with Minikube CA"
openssl x509 -req \
  -in "${BASE_DIR}/${USERNAME}.csr" \
  -CA ~/.minikube/ca.crt \
  -CAkey ~/.minikube/ca.key \
  -CAcreateserial \
  -out "${BASE_DIR}/${USERNAME}.crt" \
  -days 365

echo "Add credentials to kubeconfig"
kubectl config set-credentials "${USERNAME}" \
  --client-certificate="${BASE_DIR}/${USERNAME}.crt" \
  --client-key="${BASE_DIR}/${USERNAME}.key" \
  --embed-certs=true

echo "Create context"
kubectl config set-context "${USERNAME}@${CLUSTER_NAME}" \
  --cluster="${CLUSTER_NAME}" \
  --user="${USERNAME}"


echo "User created: ${USERNAME}"
echo "Group: ${GROUPNAME}"
echo "Context: ${USERNAME}@${CLUSTER_NAME}"
echo
echo "Use:"
echo "  kubectl config use-context ${USERNAME}@${CLUSTER_NAME}"