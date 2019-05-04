#!/usr/bin/env bash
set -eof pipefail

if [ -z ${GOOGLE_CLOUD_PROJECT} ];then
    echo "export GOOGLE_CLOUD_PROJECT=<project id>"
    exit 1
fi

gcloud --project ${GOOGLE_CLOUD_PROJECT} services enable cloudkms.googleapis.com

#gcloud --project ${GOOGLE_CLOUD_PROJECT} container operations wait

ssh-keygen -t rsa -b 4096 -C "cloudbuild@example.com" -f ./cloudbuild_ssh.key

KEYRINGS=$(gcloud --project ${GOOGLE_CLOUD_PROJECT} kms keyrings list --location=global --format="table[no-heading](name)")
if [ $(echo ${KEYRINGS} | grep "cloudbuild-keyring") ]; then 
    echo "Skiping keyring create as already exists '${KEYRINGS}'"
else
    gcloud --project ${GOOGLE_CLOUD_PROJECT} kms keyrings create cloudbuild-keyring --location=global 
fi 

KEYS=$(gcloud --project ${GOOGLE_CLOUD_PROJECT} kms keys list --keyring=cloudbuild-keyring --location=global --format="table[no-heading](name)")
if [ $(echo ${KEYS} | grep "github-key") ]; then 
    echo "Skiping key create as already exists '${KEYS}'"
else
    gcloud --project ${GOOGLE_CLOUD_PROJECT} kms keys create github-key --keyring=cloudbuild-keyring --location=global --purpose=encryption
fi 


gcloud --project ${GOOGLE_CLOUD_PROJECT} kms encrypt --plaintext-file=./cloudbuild_ssh.key --ciphertext-file=./cloudbuild_ssh.key.enc --location=global --keyring=cloudbuild-keyring --key=github-key
ssh-keyscan -t rsa github.com > known_hosts

