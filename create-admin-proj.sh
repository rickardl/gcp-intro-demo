#!/usr/bin/env bash


if [ $# -ne 0 ]
then
  echo "Usage: ./create-admin-proj.sh"
  exit 1
fi


# Create project.
echo "*** Creating admin project... ***"
gcloud projects create $TF_VAR_ADMIN_PROJ_ID --folder=$TF_VAR_FOLDER_ID --name=$TF_VAR_ADMIN_PROJ_NAME

# Create gcloud configuration for terraform parent project.
echo "*** Creating gcloud configuration... ***"
gcloud config configurations create $TF_VAR_ADMIN_PROJ_ID
gcloud config set compute/region $TF_VAR_REGION
gcloud config set compute/zone $TF_VAR_ZONE
gcloud config set account $TF_VAR_ACCOUNT
gcloud config set project $TF_VAR_ADMIN_PROJ_ID
gcloud config configurations list
gcloud config get-value project
# Assign billing account
#gcloud beta billing accounts list
gcloud beta billing projects link $TF_VAR_ADMIN_PROJ_ID --billing-account $TF_VAR_BILLING_ACCOUNT_ID

# Make Cloud storage bucket.
echo "*** Creating bucket for terraform backend... ***"
gsutil mb -p ${TF_VAR_ADMIN_PROJ_ID} -c regional -l ${TF_VAR_REGION} gs://${TF_VAR_TERRA_BACKEND_BUCKET_NAME}
gsutil versioning set on gs://${TF_VAR_TERRA_BACKEND_BUCKET_NAME}

