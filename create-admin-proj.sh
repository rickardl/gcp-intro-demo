#!/usr/bin/env bash


# Create projects.
echo "*** Creating projects... ***"
gcloud projects create $TF_VAR_ADMIN_PROJ_ID --folder=$TF_VAR_FOLDER_ID --name=$TF_VAR_ADMIN_PROJ_NAME
#gcloud projects create $TF_VAR_INFRA_PROJ_ID --folder=$TF_VAR_FOLDER_ID --name=$TF_VAR_INFRA_PROJ_NAME

# Create gcloud configuration for terraform parent project.
echo "*** Creating gcloud configuration... ***"
gcloud config configurations create $TF_VAR_CONFIG_NAME
gcloud config set compute/region $TF_VAR_REGION
gcloud config set compute/zone $TF_VAR_ZONE
gcloud config set account $TF_VAR_ACCOUNT
gcloud config set project $TF_VAR_ADMIN_PROJ_ID
gcloud config configurations list
gcloud config get-value project
# Assign billing account
#gcloud beta billing accounts list
gcloud beta billing projects link $TF_VAR_ADMIN_PROJ_ID --billing-account $TF_VAR_BILLING_ACCOUNT_ID
#gcloud beta billing projects link $TF_VAR_INFRA_PROJ_ID --billing-account $TF_VAR_BILLING_ACCOUNT_ID

# Make Cloud storage bucket.
echo "*** Creating bucket for terraform backend... ***"
gsutil mb -p ${TF_VAR_ADMIN_PROJ_ID} -c regional -l ${TF_VAR_REGION} gs://${TF_VAR_TERRA_BACKEND_BUCKET_NAME}
gsutil versioning set on gs://${TF_VAR_TERRA_BACKEND_BUCKET_NAME}

# Create service account in terraform parent project.
#echo "*** Creating service account to be used for terraform... ***"
#gcloud iam service-accounts create terraform --display-name "terraform-service-account"
#gcloud iam service-accounts keys create ${TF_VAR_CREDS} --iam-account terraform@${TF_VAR_ADMIN_PROJ_ID}.iam.gserviceaccount.com
#ll ~/.config/gcloud/
# Add roles.
#gcloud projects add-iam-policy-binding ${TF_VAR_ADMIN_PROJ_ID} --member serviceAccount:terraform@${TF_VAR_ADMIN_PROJ_ID}.iam.gserviceaccount.com --role roles/viewer
#gcloud projects add-iam-policy-binding ${TF_VAR_ADMIN_PROJ_ID} --member serviceAccount:terraform@${TF_VAR_ADMIN_PROJ_ID}.iam.gserviceaccount.com --role roles/storage.admin

#export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
#export GOOGLE_PROJECT=${TF_ADMIN_PROJ_ID}
