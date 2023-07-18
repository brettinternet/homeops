#!/bin/sh

API_SERVER="https://kubernetes.default.svc"
SERVICE_ACCOUNT_FOLDER="/var/run/secrets/kubernetes.io/serviceaccount"
NAMESPACE=$(cat ${SERVICE_ACCOUNT_FOLDER}/namespace)
TOKEN=$(cat ${SERVICE_ACCOUNT_FOLDER}/token)
CACERT="${SERVICE_ACCOUNT_FOLDER}/ca.crt"

curl -s --cacert "$CACERT" --header "Authorization: Bearer $TOKEN" -X GET "$API_SERVER/apis/apps/v1/namespaces/$NAMESPACE/pods"
