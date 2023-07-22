#!/bin/bash

set -e

DEPLOYMENTS="$1"
NUMBER_OF_REPLICAS="${2:-1}"

API_SERVER="https://kubernetes.default.svc"
SERVICE_ACCOUNT_FOLDER="/var/run/secrets/kubernetes.io/serviceaccount"
NAMESPACE=$(cat ${SERVICE_ACCOUNT_FOLDER}/namespace)
TOKEN=$(cat ${SERVICE_ACCOUNT_FOLDER}/token)
CACERT="${SERVICE_ACCOUNT_FOLDER}/ca.crt"
PAYLOAD="{\"spec\":{\"replicas\":$NUMBER_OF_REPLICAS}}"

IFS=', ' read -r -a DEPLOYMENTS_ARRAY <<< "$DEPLOYMENTS"
for DEPLOYMENT_NAME in "${DEPLOYMENTS_ARRAY[@]}"; do
  if [ ! -z "$DEPLOYMENT_NAME" ]; then
    RESULT=$(curl -s \
      --cacert "$CACERT" \
      -X PATCH \
      -H "Content-Type: application/strategic-merge-patch+json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "$PAYLOAD" \
      "$API_SERVER/apis/apps/v1/namespaces/$NAMESPACE/deployments/$DEPLOYMENT_NAME")
    RESULT_REPLICAS=$(echo "$RESULT" | jq '.spec.replicas')
    # RESULT_MESSAGES=$(echo "$RESULT" | jq '.status.conditions.[] | .message')
    echo "$DEPLOYMENT_NAME replicas: $RESULT_REPLICAS"
  fi
done
