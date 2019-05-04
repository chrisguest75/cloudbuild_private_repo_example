#!/usr/bin/env bash
set -eof pipefail

if [ -z ${GOOGLE_CLOUD_PROJECT} ];then
    echo "export GOOGLE_CLOUD_PROJECT=<project id>"
    echo "Did you configure .env file?"
    exit 1
fi

gcloud --project ${GOOGLE_CLOUD_PROJECT} kms keys add-iam-policy-binding ${KEY_NAME} --location=global --keyring=${KEYRING_NAME} --member=serviceAccount:${CLOUDBUILD_SERVICE_ACCOUNT_ID}@cloudbuild.gserviceaccount.com --role=roles/cloudkms.cryptoKeyDecrypter